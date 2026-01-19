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
  bool isEditing = false;
  bool isGuest = false;
  TextEditingController _controller = TextEditingController();

  // ---------------------------------------------------------
  // 1. ส่วนจัดการรูปภาพ (Assets & ID)
  // ---------------------------------------------------------
  // รายชื่อไฟล์รูปภาพที่เตรียมไว้ใน assets/images/
  final List<String> avatarList = [
    'assets/image/avatar_0.png', // รูปที่ 0 (ค่าเริ่มต้น)
    'assets/image/avatar_1.png', // รูปที่ 1
    'assets/image/avatar_2.png', // รูปที่ 2
    'assets/image/avatar_3.png', // รูปที่ 3
    'assets/image/avatar_4.png', // รูปที่ 4
    'assets/image/avatar_5.png', // รูปที่ 5
  ];

  int currentAvatarId = 0; // ตัวแปรเก็บ ID รูปปัจจุบัน (ค่า default คือ 0)
  // ---------------------------------------------------------

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
    loadUsername(); // โหลดข้อมูลผู้ใช้รวมถึงรูปภาพล่าสุด
  }

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
        // "เกมพูดคำศัพท์": _getTop3PerCategory(
        //   GameData.topScoresByGame["เกมพูดคำศัพท์"] ?? [],
        // ),
        "เกมทายรูปภาพ": _getTop3PerCategory(
          GameData.topScoresByGame["เกมทายรูปภาพ"] ?? [],
        ),
      };
    });
  }

  // ---------------------------------------------------------
  // 2. ปรับปรุง Logic จัดอันดับให้ดึง image_id มาด้วย
  // ---------------------------------------------------------
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

        // ** ดึงค่า image_id จากข้อมูลคะแนน (ถ้าไม่มีให้เป็น 0) **
        int imgId = int.tryParse(s["image_id"]?.toString() ?? "0") ?? 0;
        s["parsed_image_id"] = imgId; // ฝากค่าไว้ใช้ตอนแสดงผล

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
        // ดึง image_id จาก GameData ที่เราเพิ่งแก้ไป
        int userImgId =
            int.tryParse(filtered[i]["image_id"]?.toString() ?? "0") ?? 0;

        Color rankColor =
            i == 0
                ? Colors.amber
                : i == 1
                ? Colors.grey
                : i ==
                    2 // เพิ่มสีอันดับ 3 (Optional)
                ? Colors.brown
                : Colors.blueGrey; // อันดับอื่นๆ ให้เป็นสีทั่วไป

        result.add({
          "rank": (i + 1).toString(),
          "color": rankColor,
          "username": user,
          "image_id": userImgId, // ✅ ส่ง ID รูปไปแสดงผล
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

  // ---------------------------------------------------------
  // 3. ปรับปรุง UI Popup คะแนนให้แสดงรูปตาม ID
  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // 3. ปรับปรุง UI Popup คะแนน (แก้ไขเรื่อง Overflow)
  // ---------------------------------------------------------
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
      builder: (context) {
        final size = MediaQuery.of(context).size;

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            // ป้องกันความสูงเกินขอบเขตด้วย ConstrainedBox หรือกำหนด height ให้เหมาะสม
            width:
                size.width > 400
                    ? 400
                    : size.width *
                        0.95, // ถ้าจอใหญ่ล็อคความกว้าง ถ้าจอเล็กเอา 95%
            height: size.height * 0.7, // เพิ่มความสูงให้หน่อยเป็น 70%
            child: Stack(
              children: [
                DefaultTabController(
                  length: grouped.keys.length,
                  child: Column(
                    children: [
                      // --- Header ---
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          12,
                          40,
                          0,
                        ), // เว้นขวาไว้ให้ปุ่มปิด
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch, // ให้ TabBar เต็มความกว้าง
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // --- แก้ไข TabBar ---
                            TabBar(
                              isScrollable:
                                  true, // ✅ แก้ไข 1: ให้เลื่อนได้ ป้องกันล้นแนวนอน
                              tabAlignment:
                                  TabAlignment
                                      .start, // จัดชิดซ้ายเวลาเลื่อน (Flutter 3.13+)
                              indicatorColor: Colors.white,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white70,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              tabs:
                                  grouped.keys.map((c) {
                                    return Tab(
                                      // ✅ แก้ไข 2: เอา SizedBox.expand ออก ใช้แค่ Text ธรรมดา
                                      text: c,
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // เว้นระยะห่างด้านล่าง TabBar นิดหน่อย
                          ],
                        ),
                      ),

                      // --- Content List ---
                      Expanded(
                        child: TabBarView(
                          children:
                              grouped.entries.map((entry) {
                                final items = entry.value;
                                return ListView.builder(
                                  // ใช้ builder เพื่อ performance ที่ดีกว่า
                                  padding: const EdgeInsets.all(12),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final game = items[index];
                                    int pImgId = game["image_id"] ?? 0;
                                    String imgPath =
                                        (pImgId >= 0 &&
                                                pImgId < avatarList.length)
                                            ? avatarList[pImgId]
                                            : avatarList[0];

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
                                        title: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  Colors.transparent,
                                              backgroundImage: AssetImage(
                                                imgPath,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // ✅ แก้ไข 3: ใส่ Expanded ให้ชื่อ เพื่อไม่ให้ดันจนล้นจอ
                                            Expanded(
                                              child: Text(
                                                "${game["username"]}",
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis, // ตัดคำถ้ายาวเกิน
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: game["usernameColor"],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- ปุ่มปิด ---
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    // ใช้ CircleAvatar ซ้อน Icon จะสวยกว่าและกดง่าย
                    radius: 16,
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      tooltip: "ปิด",
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

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('isGuest');
    await prefs.remove('guestUsername');
    await prefs.remove('guest');
    // await prefs.remove('selected_icon');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // ---------------------------------------------------------
  // 4. โหลดข้อมูล user และ image_id จาก Database
  // ---------------------------------------------------------
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

    // -----------------------------------------------------
    // 1. ✅ โชว์ข้อมูลเก่าในเครื่องก่อน (ไม่ต้องรอเน็ต)
    // -----------------------------------------------------
    String? cachedName = prefs.getString('cached_username');
    int? cachedImageId = prefs.getInt('cached_image_id');

    if (cachedName != null) {
      setState(() {
        _controller.text = cachedName;
        currentAvatarId = cachedImageId ?? 0;
      });
    }

    // -----------------------------------------------------
    // 2. 📡 แล้วค่อยไปดึงข้อมูลล่าสุดจาก Server (อยู่เบื้องหลัง)
    // -----------------------------------------------------
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/get_user.php?id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // เช็คว่าข้อมูลเปลี่ยนไหม? ถ้าเปลี่ยนค่อย setState
        String newName = data['username'] ?? '';

        // เช็ค Key ให้ชัวร์ว่า Server ส่งอะไรมา (image_id หรือ image_number)
        var rawImg = data['image_id'] ?? data['image_number'];
        int newImageId = int.tryParse(rawImg?.toString() ?? "0") ?? 0;

        // บันทึกลงเครื่องไว้ใช้ครั้งหน้า (Cache Update)
        await prefs.setString('cached_username', newName);
        await prefs.setInt('cached_image_id', newImageId);

        // อัปเดตหน้าจออีกครั้ง
        if (mounted) {
          setState(() {
            _controller.text = newName;
            currentAvatarId = newImageId;
          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
      // ถ้าเน็ตหลุด ก็ยังโชว์ข้อมูลเก่า (cached) ได้ User ไม่เห็นหน้าว่างๆ
    }
  }

  Future<bool> saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = _controller.text.trim();

    // 1. ตรวจสอบความถูกต้อง
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

    // 2. Popup ยืนยัน (ก่อนบันทึก)
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการเปลี่ยนชื่อ'),
          content: Text('คุณต้องการเปลี่ยนชื่อเป็น "$newName" ใช่หรือไม่?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true) return false; // ถ้าไม่ยืนยัน จบการทำงาน

    // 3. เริ่มบันทึกข้อมูล
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
          print('Error updating username: $e');
        }
      }
    }

    // 4. จัดการผลลัพธ์ (แสดง SnackBar)
    if (isSuccess) {
      setState(() => isEditing = false);

      // ✅ สคิปเด้งขึ้น (SnackBar) สีเขียว เมื่อสำเร็จ
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
            backgroundColor: Colors.green, // สีเขียวสื่อถึงความสำเร็จ
            behavior:
                SnackBarBehavior.floating, // ให้ลอยขึ้นมาเหนือขอบล่างนิดหน่อย
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    } else {
      // กรณีผิดพลาด
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

  // ---------------------------------------------------------
  // 5. หน้าต่างเลือกรูปภาพ (GridView)
  // ---------------------------------------------------------
  void _showAvatarPicker() {
    // 1. สร้างตัวแปรชั่วคราว เก็บค่าเริ่มต้นเป็นรูปปัจจุบัน
    int tempSelectedId = currentAvatarId;

    showDialog(
      context: context,
      builder: (context) {
        // 2. ใช้ StatefulBuilder เพื่อให้สั่ง setState เฉพาะใน Dialog ได้ (ขอบเปลี่ยนสี)
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("เลือกรูปโปรไฟล์"),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // 3. เมื่อกดเลือกรูป ให้อัปเดตตัวแปรชั่วคราว และรีเฟรช Dialog
                        setStateDialog(() {
                          tempSelectedId = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // 4. เปรียบเทียบกับตัวแปรชั่วคราวเพื่อแสดงขอบสีฟ้า
                          border:
                              tempSelectedId == index
                                  ? Border.all(color: Colors.blue, width: 4)
                                  : Border.all(color: Colors.grey[300]!),
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
                // ปุ่มยกเลิก
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // 5. ปุ่มตกลง (Save จริงตรงนี้)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // อัปเดตค่าจริงที่หน้าจอหลัก
                    setState(() {
                      currentAvatarId = tempSelectedId;
                    });

                    // บันทึกลง Database
                    await saveSelectedImage(tempSelectedId);

                    // ปิด Popup
                    Navigator.pop(context);
                  },
                  child: const Text("ตกลง"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // บันทึก ID รูปภาพลง Server
  Future<void> saveSelectedImage(int imageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    // 1. เช็คก่อนว่ามี User ID ไหม
    if (userId == null) {
      print("❌ ไม่พบ User ID (อาจยังไม่ได้ Login หรือเป็น Guest)");
      return;
    }

    try {
      // 2. ตรวจสอบ URL และ IP Address ให้แน่ใจ
      // หมายเหตุ: ถ้าใช้ Emulator Android บางทีต้องใช้ 10.0.2.2 แทน IP เครื่อง
      final url = Uri.parse('${ApiConfig.baseUrl}/update_user_image.php');

      print("📡 กำลังส่งข้อมูล... User: $userId, Image: $imageNumber");

      final response = await http.post(
        url,
        // เพิ่ม Header เพื่อความชัวร์ (บาง Server ต้องการ)
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'user_id': userId.toString(),
          'image_number': imageNumber.toString(),
        },
      );

      // 3. ดูสิ่งที่ Server ตอบกลับมา (สำคัญมาก!)
      print("📩 Server Status Code: ${response.statusCode}");
      print("📩 Server Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // ลอง Decode JSON
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            print('✅ เปลี่ยนรูปโปรไฟล์สำเร็จ: ID $imageNumber');
            // อาจจะเพิ่ม logic แจ้งเตือนผู้ใช้ เช่น showSnackBar ตรงนี้
          } else {
            print(
              '❌ Server แจ้งว่าบันทึกไม่สำเร็จ: ${data['error'] ?? data['message']}',
            );
          }
        } catch (e) {
          print(
            "❌ JSON Decode Error: ข้อมูลที่ส่งกลับไม่ใช่ JSON (อาจเป็น HTML Error)",
          );
        }
      } else {
        print("❌ เชื่อมต่อ Server ไม่ได้ (Status: ${response.statusCode})");
      }
    } catch (e) {
      print('❌ Error saving selected image (Exception): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayImage =
        avatarList.isNotEmpty
            ? avatarList[currentAvatarId < avatarList.length
                ? currentAvatarId
                : 0]
            : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black45,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text("ตั้งค่า"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("เสียงเกม"),
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
                                const Text("เสียงปุ่ม"),
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
                                        title: const Text(
                                          "คุณต้องการออกจากระบบหรือไม่?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text("ยกเลิก"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red[400],
                                            ),
                                            onPressed: () => logout(context),
                                            child: const Text(
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
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
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
                                child: const Text("เสร็จสิ้น"),
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
      backgroundColor: Colors.amber[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _showAvatarPicker,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                displayImage.isNotEmpty
                                    ? AssetImage(displayImage)
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 200,
                          child:
                              isEditing
                                  ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          textAlign: TextAlign.center,
                                          autofocus: true,
                                          maxLength: 12,
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            hintText: 'กรอกชื่อไม่เกิน 20 ตัว',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () async {
                                          final success = await saveUsername();
                                          if (success) {
                                            FocusScope.of(context).unfocus();
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 18),
                                      Flexible(
                                        child: Text(
                                          _controller.text.isEmpty
                                              ? "ตั้งชื่อของคุณ"
                                              : _controller.text,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
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
                ),
                const SizedBox(height: 10),
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
                            itemCount: gameList.length,
                            itemBuilder: (context, index) {
                              final game = gameList[index];
                              String titleEn = game['title_en'] ?? "Game Name";
                              String titleTh = game['title_th'] ?? "ชื่อเกม";
                              String imagePath = game['image'] ?? "";

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () => showGamePopup(titleTh),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
                                    foregroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child:
                                            imagePath.isNotEmpty
                                                ? Image.asset(
                                                  imagePath,
                                                  fit: BoxFit.contain,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.games,
                                                        color: Colors.orange,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.games,
                                                  color: Colors.orange,
                                                ),
                                      ),

                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              titleEn,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              titleTh,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.orange,
                                        size: 18,
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
