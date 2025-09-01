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
  TextEditingController _controller = TextEditingController();
  IconData selectedIcon = Icons.person;
  List<Map<String, dynamic>> games = [];
  List<Map<String, dynamic>> games1 = List.generate(
    3,
    (index) => {
      "icon": Icons.emoji_events,
      "color":
          index == 0
              ? Colors.amber
              : index == 1
              ? Colors.grey
              : Colors.brown,
      "username": "",
      "category": "",
      "score": "คะแนน",
      "time": "",
    },
  );

  List<Map<String, dynamic>> games2 = List.generate(
    3,
    (index) => {
      "icon": Icons.emoji_events,
      "color":
          index == 0
              ? Colors.amber
              : index == 1
              ? Colors.grey
              : Colors.brown,
      "username": "",
      "category": "",
      "score": "คะแนน",
      "time": "",
    },
  );

  List<Map<String, dynamic>> games3 = List.generate(
    3,
    (index) => {
      "icon": Icons.emoji_events,
      "color":
          index == 0
              ? Colors.amber
              : index == 1
              ? Colors.grey
              : Colors.brown,
      "username": "",
      "category": "",
      "score": "คะแนน",
      "time": "",
    },
  );

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('isGuest');
    await prefs.remove('guestUsername');
    await prefs.remove('guestBirthday');
    await prefs.remove('guestAge');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadScores();
  }

  // ดึงชื่อผู้ใช้จาก PHP API
  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id'); // ดึง id จริง
    if (userId != null) {
      GameData.userId = userId;
    }
    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _controller.text = prefs.getString('guestUsername') ?? 'Guest';
      });
      return;
    }

    if (userId == null) return; // ยังไม่ได้ login

    try {
      final url = Uri.parse(
        'http://192.168.1.112/dataweb/get_user.php?id=$userId',
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

  // บันทึกชื่อผู้ใช้ไปยัง PHP API
  Future<void> saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? false;

    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    if (isGuest) {
      await prefs.setString('guestUsername', newName);
      setState(() => isEditing = false);
      return;
    }

    // สำหรับ User ปกติ
    int? userId = prefs.getInt('id');
    if (userId == null) return;

    try {
      final url = Uri.parse('http://192.168.1.112/dataweb/update_user.php');
      final response = await http.post(
        url,
        body: {'id': userId.toString(), 'username': newName},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      print('Error updating username: $e');
    }
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
                  _buildIconChoice(Icons.person, tempIcon, (icon) {
                    setStateDialog(() {
                      tempIcon = icon;
                    });
                  }),
                  _buildIconChoice(Icons.account_circle, tempIcon, (icon) {
                    setStateDialog(() {
                      tempIcon = icon;
                    });
                  }),
                  _buildIconChoice(Icons.face, tempIcon, (icon) {
                    setStateDialog(() {
                      tempIcon = icon;
                    });
                  }),
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
                setState(() {
                  selectedIcon = tempIcon;
                });
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(icon, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> groupByCategory(
    List<Map<String, dynamic>> games,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var game in games) {
      final category = game["category"] ?? "ไม่ระบุหมวด";
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(game);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _getTop3PerCategory(List<dynamic> scores) {
    Map<String, List<dynamic>> grouped = {};

    for (var score in scores) {
      String category = score["category"] ?? "ไม่ระบุหมวด";
      grouped.putIfAbsent(category, () => []).add(score);
    }

    List<Map<String, dynamic>> result = [];

    grouped.forEach((category, list) {
      list.sort((a, b) => (b["score"] ?? 0).compareTo(a["score"] ?? 0));
      for (int i = 0; i < list.length && i < 3; i++) {
        result.add({
          "icon": Icons.emoji_events,
          "color":
              i == 0
                  ? Colors.amber
                  : i == 1
                  ? Colors.grey
                  : Colors.brown,
          "username": list[i]["username"] ?? "",
          "category": category,
          "score": "${list[i]["score"] ?? 0} คะแนน",
          "time": list[i]["time"] ?? "",
        });
      }
    });

    return result;
  }

  Future<void> loadScores() async {
    await GameData.loadTopScores();
    await GameData.loadTopScores1();
    games1 = _getTop3PerCategory(
      GameData.topScoresByGame["เกมทายคำศัพท์"] ?? [],
    );
    games2 = _getTop3PerCategory(
      GameData.topScoresByGame["เกมจับคู่คำศัพท์"] ?? [],
    );
    games3 = _getTop3PerCategory(GameData.topScoresByGame["เกมเติมคำ"] ?? []);
    setState(() {
      games = [
        {
          "icon": Icons.emoji_events,
          "color": Colors.amber,
          "name": GameData.showName1,
          "category": GameData.showTitle1,
          "score": "${GameData.showScore1} คะแนน",
        },
        {
          "icon": Icons.emoji_events,
          "color": Colors.grey,
          "name": GameData.showName2,
          "category": GameData.showTitle2,
          "score": "${GameData.showScore2} คะแนน",
        },
        {
          "icon": Icons.emoji_events,
          "color": Colors.brown,
          "name": GameData.showName3,
          "category": GameData.showTitle3,
          "score": "${GameData.showScore3} คะแนน",
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.white, height: 1.0),
        ),
        actions: <Widget>[
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            ),
                          ],
                        ),
                        actions: <Widget>[
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
                      );
                    },
                  );
                },
                barrierDismissible: false,
              );
            },
          ),
        ],
        backgroundColor: Color(0xFFFFF895),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 พื้นหลัง
          Image.asset('assets/image/bg.png', fit: BoxFit.cover),
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
                    isEditing
                        ? Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            maxLength: 20,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'กรอกชื่อไม่เกิน 20 ตัว',
                            ),
                          ),
                        )
                        : Expanded(
                          child: Text(
                            _controller.text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        if (isEditing) {
                          saveUsername();
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ...games.map((game) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(game["icon"], color: game["color"], size: 24),
                        SizedBox(width: 16),
                        Text(game["name"], style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Text(
                          game["category"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          game["score"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // backgroundColor: Color(0xFFFF6B81),
                  ),
                  onPressed: () {
                    SoundManager.playClickSound();
                    final grouped = groupByCategory(games1);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("อันดับคะแนนเกมทายคำ"),
                          content: Container(
                            height: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    grouped.entries.map((entry) {
                                      final category = entry.key;
                                      final items = entry.value;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "📂 $category",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ...items.map((game) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    game["icon"],
                                                    color: game["color"],
                                                    size: 24,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "👤 ${game["username"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "⏱ ${game["time"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    "${game["score"]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "อันดับคะแนนเกมทายคำ",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    SoundManager.playClickSound();
                    final grouped = groupByCategory(games2);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("อันดับคะแนนเกมจับคู่"),
                          content: Container(
                            height: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    grouped.entries.map((entry) {
                                      final category = entry.key;
                                      final items = entry.value;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "📂 $category",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ...items.map((game) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    game["icon"],
                                                    color: game["color"],
                                                    size: 24,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "👤 ${game["username"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "⏱ ${game["time"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    "${game["score"]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "อันดับคะแนนเกมจับคู่",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    SoundManager.playClickSound();
                    final grouped = groupByCategory(games3);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("อันดับคะแนนเติมคำ"),
                          content: Container(
                            height: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    grouped.entries.map((entry) {
                                      final category = entry.key;
                                      final items = entry.value;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "📂 $category",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ...items.map((game) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    game["icon"],
                                                    color: game["color"],
                                                    size: 24,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "👤 ${game["username"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          "⏱ ${game["time"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    "${game["score"]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "อันดับคะแนนเติมคำ",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(300, 50),
                      backgroundColor: Colors.red[400],
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      // ),
                    ),
                    onPressed: () {
                      SoundManager.playClickSound();
                      // แสดง AlertDialog เมื่อกดปุ่มปิด
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("คุณต้องการออกจากระบบหรือไม่?"),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("ยกเลิก"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.red[400],
                                  ),
                                  onPressed: () {
                                    logout(context);
                                  },
                                  child: Text(
                                    "ออกจากระบบ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        barrierDismissible: false,
                      );
                    },
                    child: Text(
                      "ลงชื่อออกจากระบบ",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
