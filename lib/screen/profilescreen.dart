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
  bool isEditing = false;
  bool isGuest = false;
  TextEditingController _controller = TextEditingController();
  IconData selectedIcon = Icons.person;
  Map<String, List<Map<String, dynamic>>> topScores = {};
  String currentUsername = "";
  final List<String> gameTitles = [
    "เกมทายคำศัพท์",
    "เกมจับคู่คำศัพท์",
    "เกมเติมคำ",
    "เกมพูดคำศัพท์",
    "เกมทายรูปภาพ",
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
    _loadSelectedIcon();
  }

  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId == null) return "";

    try {
      final url = Uri.parse(
        'http://10.33.87.68/dataweb/get_user.php?id=$userId',
      );
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
        "เกมพูดคำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมพูดคำศัพท์"] ?? [],
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
        if (!bestScores.containsKey(user) ||
            (s["score"] ?? 0) > (bestScores[user]!["score"] ?? 0)) {
          bestScores[user] = s;
        }
      }

      List<Map<String, dynamic>> filtered =
          bestScores.values.toList()
            ..sort((a, b) => (b["score"] ?? 0).compareTo(a["score"] ?? 0));

      for (int i = 0; i < filtered.length && i < 3; i++) {
        String user = filtered[i]["username"] ?? "";
        Color rankColor =
            i == 0
                ? Colors.amber
                : i == 1
                ? Colors.grey
                : Colors.brown;

        result.add({
          "rank": (i + 1).toString(),
          "color": rankColor,
          "username": user,
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

  void showGamePopup(String title) {
    final scores = topScores[title] ?? [];
    final grouped = _groupByCategory(scores);

    if (scores.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(title),
              content: const Text("ยังไม่มีข้อมูลคะแนน"),
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
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: DefaultTabController(
            length: grouped.keys.length,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TabBar(
                        isScrollable: false,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black87,
                        labelPadding: EdgeInsets.zero,
                        tabs:
                            grouped.keys.map((c) {
                              return Tab(
                                child: SizedBox.expand(
                                  child: Center(
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children:
                        grouped.entries.map((entry) {
                          final items = entry.value;
                          return ListView(
                            padding: const EdgeInsets.all(12),
                            children:
                                items.map((game) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: game["color"],
                                        child: Text(
                                          game["rank"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        "👤 ${game["username"]}",
                                        style: TextStyle(
                                          color: game["usernameColor"],
                                        ),
                                      ),
                                      subtitle: Text("⏱ ${game["time"]}"),
                                      trailing: Text(
                                        game["score"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadSelectedIcon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? iconCode = prefs.getInt('selected_icon');
    if (iconCode != null) {
      setState(() {
        selectedIcon = IconData(iconCode, fontFamily: 'MaterialIcons');
      });
    }
  }

  void _saveSelectedIcon(IconData icon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_icon', icon.codePoint);
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('isGuest');
    await prefs.remove('guestUsername');
    await prefs.remove('selected_icon');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId != null) GameData.userId = userId;
    isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _controller.text = prefs.getString('guestUsername') ?? 'Guest';
      });
      return;
    }

    if (userId == null) return;

    try {
      final url = Uri.parse(
        'http://10.33.87.68/dataweb/get_user.php?id=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _controller.text = data['username'] ?? 'Guest';
        });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ชื่อผู้ใช้งานไม่เหมาะสม')));
      return false;
    }

    if (isGuest) {
      await prefs.setString('guestUsername', newName);
      setState(() => isEditing = false);
      return true;
    }

    int? userId = prefs.getInt('id');
    if (userId == null) return false;

    try {
      final url = Uri.parse('http://10.33.87.68/dataweb/update_user.php');
      final response = await http.post(
        url,
        body: {'id': userId.toString(), 'username': newName},
      );
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() => isEditing = false);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'เกิดข้อผิดพลาด')),
        );
        return false;
      }
    } catch (e) {
      print('Error updating username: $e');
      return false;
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

  String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\._\-]'), '')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll('7', 't');
  }

  bool isBadUsername(String username) {
    final normalized = normalizeText(username);
    for (final word in bannedWords) {
      if (normalized.contains(word)) return true;
    }
    return false;
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อสำเร็จ'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPicker() {
    IconData tempIcon = selectedIcon;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("เลือกรูปโปรไฟล์"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconChoice(
                    Icons.person,
                    tempIcon,
                    (icon) => setStateDialog(() => tempIcon = icon),
                  ),
                  _buildIconChoice(
                    Icons.account_circle,
                    tempIcon,
                    (icon) => setStateDialog(() => tempIcon = icon),
                  ),
                  _buildIconChoice(
                    Icons.face,
                    tempIcon,
                    (icon) => setStateDialog(() => tempIcon = icon),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => selectedIcon = tempIcon);
                _saveSelectedIcon(tempIcon);
                Navigator.pop(context);
              },
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconChoice(
    IconData icon,
    IconData selected,
    void Function(IconData) onSelected,
  ) {
    final bool isSelected = icon == selected;
    return GestureDetector(
      onTap: () => onSelected(icon),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                isSelected ? Border.all(color: Colors.blue, width: 3) : null,
          ),
          padding: EdgeInsets.all(4),
          child: Icon(icon, size: 40),
        ),
      ),
    );
  }

  // 🔹 ฟังก์ชันบันทึกภาพที่เลือกจากเกมบน server
  Future<void> saveSelectedImage(int imageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) return;

    try {
      final url = Uri.parse('http://10.33.87.68/dataweb/update_user_image.php');
      final response = await http.post(
        url,
        body: {
          'user_id': userId.toString(),
          'image_number': imageNumber.toString(),
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('✅ เลือกรูปสำเร็จ');
      }
    } catch (e) {
      print('Error saving selected image: $e');
    }
  }

  // 🔹 แก้ path รูปจาก assets -> uploads/user
  Widget _buildGameImageChoice(int imageNumber) {
    return GestureDetector(
      onTap: () async {
        await saveSelectedImage(imageNumber);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('คุณเลือกรูปที่ $imageNumber')));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          'http://10.33.87.68/uploads/user/image_$imageNumber.png',
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text("ตั้งค่า"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("เสียงเกม"),
                                Switch(
                                  value: SoundManager.isSoundOn[0],
                                  onChanged: (bool value) {
                                    setState(() {
                                      SoundManager.playClickSound();
                                      SoundManager.isSoundOn[0] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("เสียงปุ่ม"),
                                Switch(
                                  value: SoundManager.isSoundOn[1],
                                  onChanged: (bool value) {
                                    setState(() {
                                      SoundManager.playClickSound();
                                      SoundManager.isSoundOn[1] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  SoundManager.playClickSound();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "คุณต้องการออกจากระบบหรือไม่?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("ยกเลิก"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red[400],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            onPressed: () {
                                              logout(context);
                                            },
                                            child: Text(
                                              "ออกจากระบบ",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(Icons.logout, color: Colors.white),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  SoundManager.playClickSound();
                                  Navigator.of(context).pop();
                                },
                                child: Text("เสร็จสิ้น"),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.orangeAccent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          selectedIcon,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child:
                          isEditing
                              ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      autofocus: true,
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'กรอกชื่อไม่เกิน 20 ตัว',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: () async {
                                      final success = await saveUsername();
                                      if (success) {
                                        _showSuccessDialog(
                                          'เปลี่ยนชื่อเรียบร้อยแล้ว',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              )
                              : Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          _controller.text,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed:
                                              () => setState(
                                                () => isEditing = true,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "🏆 เลือกเกมที่ต้องการดูคะแนน",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: gameTitles.length,
                            itemBuilder: (context, index) {
                              final title = gameTitles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton(
                                  onPressed: () => showGamePopup(title),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.videogame_asset),
                                      const SizedBox(width: 8),
                                      Text(
                                        title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
        ],
      ),
    );
  }
}
