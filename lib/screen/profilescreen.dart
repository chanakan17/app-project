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
  final List<String> gameTitles = [
    "เกมทายคำศัพท์",
    "เกมจับคู่คำศัพท์",
    "เกมเติมคำ",
    // "เกมพูดคำศัพท์",
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
    loadUsername(); // โหลดข้อมูลผู้ใช้รวมถึงรูปภาพล่าสุด
  }

  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId == null) return "";

    try {
      final url = Uri.parse(
        'http://10.161.225.68/dataweb/get_user.php?id=$userId',
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
        // แก้ (_) เป็น (context) เพื่อดึงขนาดหน้าจอ

        // 1. ดึงขนาดหน้าจอ
        final size = MediaQuery.of(context).size;

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // 2. กำหนดขนาด Popup ที่นี่ (SizedBox)
          child: SizedBox(
            width: size.width * 0.9, // กว้าง 90% ของจอ
            height: size.height * 0.6, // สูง 60% ของจอ (ปรับเลขได้ตามต้องการ)
            // 3. ใช้ Stack เพื่อวางเนื้อหา และ ปุ่มปิด ซ้อนกัน
            child: Stack(
              children: [
                // ชั้นล่าง: เนื้อหา (Tabs และ List)
                DefaultTabController(
                  length: grouped.keys.length,
                  child: Column(
                    children: [
                      // ส่วน Header สีส้ม
                      Container(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 12,
                          right: 40,
                        ), // right 40 เผื่อที่ให้ปุ่มปิด
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

                      // ส่วนเนื้อหา List รายชื่อ
                      Expanded(
                        child: TabBarView(
                          children:
                              grouped.entries.map((entry) {
                                final items = entry.value;
                                return ListView(
                                  padding: const EdgeInsets.all(12),
                                  children:
                                      items.map((game) {
                                        // Logic รูปภาพ (Code ที่เราแก้กันก่อนหน้านี้)
                                        int pImgId = game["image_id"] ?? 0;
                                        String imgPath =
                                            (pImgId >= 0 &&
                                                    pImgId < avatarList.length)
                                                ? avatarList[pImgId]
                                                : avatarList[0];

                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
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
                                                Text(
                                                  "${game["username"]}",
                                                  style: TextStyle(
                                                    color:
                                                        game["usernameColor"],
                                                    fontWeight: FontWeight.bold,
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
                                      }).toList(),
                                );
                              }).toList(),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.black26,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          tooltip: "ปิด",
                        ),
                      ),
                    ],
                  ),
                ),
                // ชั้นบน: ปุ่มปิด (X) มุมขวาบน
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
    // await prefs.remove('selected_icon'); // ไม่ต้องลบก็ได้ หรือจะลบก็ได้
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
    if (userId != null) GameData.userId = userId;
    isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _controller.text = prefs.getString('guestUsername') ?? 'Guest';
        currentAvatarId = 0; // Guest ใช้รูป Default
      });
      return;
    }

    if (userId == null) return;

    try {
      final url = Uri.parse(
        'http://10.161.225.68/dataweb/get_user.php?id=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _controller.text = data['username'] ?? 'Guest';
          // ** ดึงค่า image_id จาก Database มาใส่ตัวแปร **
          currentAvatarId =
              int.tryParse(data['image_id']?.toString() ?? "0") ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
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
          final url = Uri.parse('http://10.161.225.68/dataweb/update_user.php');
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
      final url = Uri.parse(
        'http://10.161.225.68/dataweb/update_user_image.php',
      );

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
    // ป้องกัน index เกินขอบเขต
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              // --- Popup Setting (เหมือนเดิม) ---
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
      backgroundColor: Colors.orangeAccent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    // ---------------------------------------------------------
                    // 6. แสดงรูปโปรไฟล์ในหน้าหลัก
                    // ---------------------------------------------------------
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            displayImage.isNotEmpty
                                ? AssetImage(displayImage)
                                : null,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        hintText: 'กรอกชื่อไม่เกิน 20 ตัว',
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
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          _controller.text,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
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
                const SizedBox(height: 20),
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
