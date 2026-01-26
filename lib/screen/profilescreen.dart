import 'package:app/api_config.dart';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/screen/login/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/management/sound/sound.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});
  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  // --- Style Constants ---
  final Color primaryColor = Colors.orange;
  final Color secondaryColor = const Color(0xFFFFE0B2); // Orange[100]
  final Color accentColor = const Color(0xFFFFF8E1); // Cream
  final BorderRadius mainRadius = BorderRadius.circular(20);

  bool isEditing = false;
  bool isGuest = false;
  TextEditingController _controller = TextEditingController();

  final List<String> avatarList = [
    'assets/image/avatar_0.png',
    'assets/image/avatar_1.png',
    'assets/image/avatar_2.png',
    'assets/image/avatar_3.png',
    'assets/image/avatar_4.png',
    'assets/image/avatar_5.png',
  ];

  int currentAvatarId = 0;
  Map<String, List<Map<String, dynamic>>> topScores = {};
  String currentUsername = "";

  final List<Map<String, String>> gameList = [
    {
      "title_en": "Guessing Game",
      "title_th": "เกมทายคำศัพท์",
      "image": "assets/icons/guess.png",
    },
    {
      "title_en": "Matching Game",
      "title_th": "เกมจับคู่คำศัพท์",
      "image": "assets/icons/match.png",
    },
    {
      "title_en": "Completion Game",
      "title_th": "เกมเติมคำ",
      "image": "assets/icons/add.png",
    },
    {
      "title_en": "Picture Game",
      "title_th": "เกมทายรูปภาพ",
      "image": "assets/icons/pic.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUsername().then((value) {
      setState(() {
        currentUsername = value;
      });
      loadScores();
    });
    loadUsername();
  }

  // --- API & Data Loading Methods (Logic เดิม) ---
  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId == null) return "";
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/get_user.php?id=$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['username'] ?? "";
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return "";
  }

  Future<void> loadScores() async {
    await GameData.loadTopScores();
    await GameData.loadTopScores1();
    setState(() {
      topScores = {
        "เกมทายคำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมทายคำศัพท์"] ?? [],
        ),
        "เกมจับคู่คำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมจับคู่คำศัพท์"] ?? [],
        ),
        "เกมเติมคำ": _getTop3PerCategory(
          GameData.topScoresByGame["เกมเติมคำ"] ?? [],
        ),
        "เกมทายรูปภาพ": _getTop3PerCategory(
          GameData.topScoresByGame["เกมทายรูปภาพ"] ?? [],
        ),
      };
    });
  }

  List<Map<String, dynamic>> _getTop3PerCategory(List<dynamic> scores) {
    Map<String, List<dynamic>> grouped = {};
    for (var score in scores) {
      String category = score["category"] ?? "ไม่ระบุหมวด";
      grouped.putIfAbsent(category, () => []).add(score);
    }

    List<Map<String, dynamic>> result = [];
    grouped.forEach((category, list) {
      Map<String, Map<String, dynamic>> bestScores = {};
      for (var s in list) {
        String user = s["username"] ?? "ไม่ระบุชื่อ";
        int imgId = int.tryParse(s["image_id"]?.toString() ?? "0") ?? 0;
        s["parsed_image_id"] = imgId;

        if (!bestScores.containsKey(user) ||
            (s["score"] ?? 0) > (bestScores[user]!["score"] ?? 0)) {
          bestScores[user] = s;
        }
      }

      List<Map<String, dynamic>> filtered =
          bestScores.values.toList()
            ..sort((a, b) => (b["score"] ?? 0).compareTo(a["score"] ?? 0));

      for (int i = 0; i < filtered.length; i++) {
        String user = filtered[i]["username"] ?? "";
        int userImgId =
            int.tryParse(filtered[i]["image_id"]?.toString() ?? "0") ?? 0;

        Color rankColor =
            i == 0
                ? Colors.amber
                : i == 1
                ? Colors.grey
                : i == 2
                ? const Color(0xFFA1887F) // Brown
                : Colors.blueGrey;

        result.add({
          "rank": (i + 1).toString(),
          "color": rankColor,
          "username": user,
          "image_id": userImgId,
          "usernameColor": user == currentUsername ? Colors.blue : Colors.black,
          "category": category,
          "score": "${filtered[i]["score"] ?? 0} คะแนน",
          "time": filtered[i]["time"] ?? "",
        });
      }
    });
    return result;
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var game in data) {
      final category = game["category"] ?? "ไม่ระบุหมวด";
      grouped.putIfAbsent(category, () => []).add(game);
    }
    return grouped;
  }

  // --- 4. Load & Save User Data Methods ---
  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _controller.text = prefs.getString('guestUsername') ?? 'Guest';
        currentAvatarId = 0;
      });
      return;
    }
    if (userId == null) return;

    String? cachedName = prefs.getString('cached_username');
    int? cachedImageId = prefs.getInt('cached_image_id');

    if (cachedName != null) {
      setState(() {
        _controller.text = cachedName;
        currentAvatarId = cachedImageId ?? 0;
      });
    }

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/get_user.php?id=$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String newName = data['username'] ?? '';
        var rawImg = data['image_id'] ?? data['image_number'];
        int newImageId = int.tryParse(rawImg?.toString() ?? "0") ?? 0;

        await prefs.setString('cached_username', newName);
        await prefs.setInt('cached_image_id', newImageId);

        if (mounted) {
          setState(() {
            _controller.text = newName;
            currentAvatarId = newImageId;
          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<bool> saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = _controller.text.trim();

    if (newName.isEmpty) return false;
    if (isBadUsername(newName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ชื่อผู้ใช้งานไม่เหมาะสม'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    bool isSuccess = false;
    String? errorMessage;

    if (isGuest) {
      await prefs.setString('guestUsername', newName);
      isSuccess = true;
    } else {
      int? userId = prefs.getInt('id');
      if (userId != null) {
        try {
          final url = Uri.parse('${ApiConfig.baseUrl}/update_user.php');
          final response = await http.post(
            url,
            body: {'id': userId.toString(), 'username': newName},
          );
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            isSuccess = true;
          } else {
            errorMessage = data['error'];
          }
        } catch (e) {
          errorMessage = 'เชื่อมต่อ Server ไม่ได้';
        }
      }
    }

    if (isSuccess) {
      setState(() => isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("เปลี่ยนชื่อเรียบร้อยแล้ว"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> saveSelectedImage(int imageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) return;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/update_user_image.php');
      await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'user_id': userId.toString(),
          'image_number': imageNumber.toString(),
        },
      );
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  final Set<String> bannedWords = {
    'ควย',
    'หี',
    'เย็ด',
    'สัส',
    'เหี้ย',
    'เงี่ยน',
    'ควาย',
    'แม่ง',
    'อีดอก',
    'อีเหี้ย',
    'hee',
    'kuy',
    'fuck',
    'shit',
    'pussy',
    'dick',
    'cock',
  };

  bool isBadUsername(String username) {
    String normalized = username.toLowerCase().replaceAll(
      RegExp(r'[\s\._\-]'),
      '',
    );
    for (final word in bannedWords) {
      if (normalized.contains(word)) return true;
    }
    return false;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('isGuest');
    await prefs.remove('guestUsername');
    await prefs.remove('guest');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // --- 5. Dialogs (Avatar Picker, Settings, Score) ---

  void _showAvatarPicker() {
    int tempSelectedId = currentAvatarId;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: mainRadius),
              title: const Text("เลือกรูปโปรไฟล์", textAlign: TextAlign.center),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    bool isSelected = tempSelectedId == index;
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() => tempSelectedId = index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? primaryColor : Colors.grey[300]!,
                            width: isSelected ? 4 : 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            avatarList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    setState(() => currentAvatarId = tempSelectedId);
                    await saveSelectedImage(tempSelectedId);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "บันทึก",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    SoundManager.playClickSound();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: mainRadius),
              title: const Text(
                "ตั้งค่า",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSwitchTile("เสียงเกม", 0, setStateDialog),
                  const Divider(),
                  _buildSwitchTile("เสียงปุ่ม", 1, setStateDialog),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Logout Confirm
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("ออกจากระบบ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("ยกเลิก"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => logout(context),
                                    child: const Text(
                                      "ออก",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "ออกจากระบบ",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "เสร็จสิ้น",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile(String title, int index, Function setStateDialog) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(
            activeColor: primaryColor,
            value: SoundManager.isSoundOn[index],
            onChanged: (bool value) {
              setStateDialog(() {
                SoundManager.playClickSound();
                SoundManager.isSoundOn[index] = value;
              });
              setState(() {}); // Update main UI if needed
            },
          ),
        ],
      ),
    );
  }

  void showGamePopup(String title) {
    final scores = topScores[title] ?? [];
    final grouped = _groupByCategory(scores);

    if (scores.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: mainRadius),
              title: Text(title, textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/no_data.png',
                    width: 80,
                    height: 80,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.emoji_events_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ยังไม่มีข้อมูลคะแนน",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ปิด"),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: mainRadius),
          child: SizedBox(
            width: size.width > 400 ? 400 : size.width * 0.95,
            height: size.height * 0.75,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 40, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, Colors.orangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      width: double.infinity,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: DefaultTabController(
                        length: grouped.keys.length,
                        child: Column(
                          children: [
                            Container(
                              color: primaryColor,
                              child: TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicatorColor: Colors.white,
                                indicatorWeight: 3,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                tabs:
                                    grouped.keys
                                        .map((c) => Tab(text: c))
                                        .toList(),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children:
                                    grouped.entries.map((entry) {
                                      final items = entry.value;

                                      int myRankIndex = items.indexWhere(
                                        (item) =>
                                            item["username"] == currentUsername,
                                      );
                                      Map<String, dynamic>? myData;
                                      if (myRankIndex != -1) {
                                        myData = items[myRankIndex];
                                      }

                                      String myImgPath = avatarList[0];
                                      if (myData != null) {
                                        int pImgId = myData["image_id"] ?? 0;
                                        myImgPath =
                                            (pImgId >= 0 &&
                                                    pImgId < avatarList.length)
                                                ? avatarList[pImgId]
                                                : avatarList[0];
                                      }
                                      final top20Items = items.take(5).toList();

                                      return Column(
                                        children: [
                                          if (myData != null)
                                            Container(
                                              margin: const EdgeInsets.all(12),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFFFF8E1,
                                                ), // Cream color
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.orange.shade200,
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 42,
                                                    height: 42,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[700],
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          blurRadius: 2,
                                                          color: Colors.black26,
                                                        ),
                                                      ],
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      myData["rank"],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage: AssetImage(
                                                      myImgPath,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${myData["username"]}",
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .blue[700],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .timer_outlined,
                                                              size: 14,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "${myData["time"]}",
                                                              style:
                                                                  const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    myData["score"],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          if (myData != null)
                                            const Divider(
                                              height: 1,
                                              indent: 20,
                                              endIndent: 20,
                                            ),

                                          Expanded(
                                            child: ListView.builder(
                                              padding: const EdgeInsets.all(12),
                                              itemCount: top20Items.length,
                                              itemBuilder: (context, index) {
                                                final game = top20Items[index];
                                                int pImgId =
                                                    game["image_id"] ?? 0;
                                                String imgPath =
                                                    (pImgId >= 0 &&
                                                            pImgId <
                                                                avatarList
                                                                    .length)
                                                        ? avatarList[pImgId]
                                                        : avatarList[0];
                                                bool isMe =
                                                    game["username"] ==
                                                    currentUsername;

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isMe
                                                            ? Colors
                                                                .blue
                                                                .shade50
                                                            : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.03),
                                                        blurRadius: 3,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          game["color"],
                                                      child: Text(
                                                        game["rank"],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          backgroundImage:
                                                              AssetImage(
                                                                imgPath,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "${game["username"]}",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  game["usernameColor"],
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Text(
                                                      "⏱ ${game["time"]}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                      game["score"],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Close Button
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.black26,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    String displayImage =
        avatarList.isNotEmpty
            ? avatarList[currentAvatarId < avatarList.length
                ? currentAvatarId
                : 0]
            : "";

    return Scaffold(
      extendBodyBehindAppBar:
          true, // ให้ Body อยู่หลัง AppBar ได้ถ้าต้องการ transparent
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _showSettingsDialog,
            ),
          ),
        ],
      ),
      // ใช้ Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- Profile Header Section ---
              _buildProfileHeader(displayImage),

              const SizedBox(height: 20),

              // --- Game List Section ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events, color: primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              "Rankings & Scores",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: gameList.length,
                          itemBuilder: (context, index) {
                            return _buildGameCard(gameList[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Profile Header ---
  Widget _buildProfileHeader(String displayImage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _showAvatarPicker,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      displayImage.isNotEmpty ? AssetImage(displayImage) : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cameraswitch,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name Edit Section
        GestureDetector(
          onTap: () {
            setState(() {
              if (!isEditing) {
                isEditing = true;
                // auto focus is tricky with just setState, usually needs logic but this works for basic switch
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEditing)
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLength: 12,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: 'ป้อนชื่อ...',
                        hintStyle: TextStyle(color: Colors.white70),
                        isDense: true,
                      ),
                    ),
                  )
                else
                  Text(
                    _controller.text.isEmpty
                        ? "ตั้งชื่อของคุณ"
                        : _controller.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                const SizedBox(width: 8),
                if (isEditing)
                  InkWell(
                    onTap: () async {
                      final success = await saveUsername();
                      if (success) FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.edit, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(Map<String, String> game) {
    String titleEn = game['title_en'] ?? "";
    String titleTh = game['title_th'] ?? "";
    String imagePath = game['image'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showGamePopup(titleTh),
          splashColor: Colors.orange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0), // Orange[50]
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      imagePath.isNotEmpty
                          ? Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.videogame_asset,
                                  color: Colors.orange,
                                ),
                          )
                          : const Icon(
                            Icons.videogame_asset,
                            color: Colors.orange,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleEn,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        titleTh,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.orange, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
