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

  @override
  void initState() {
    super.initState();
    loadUsername();
    _loadSelectedIcon();
  }

  // ดึงชื่อผู้ใช้จาก PHP API
  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id'); // ดึง id จริง
    if (userId != null) {
      GameData.userId = userId;
    }
    isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _controller.text = prefs.getString('guestUsername') ?? 'Guest';
      });
      return;
    }

    if (userId == null) return; // ยังไม่ได้ login

    try {
      final url = Uri.parse(
        'http://192.168.1.125/dataweb/get_user.php?id=$userId',
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

    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      await prefs.setString('guestUsername', newName);
      setState(() => isEditing = false);
      return true;
    }

    int? userId = prefs.getInt('id');
    if (userId == null) return false;

    try {
      final url = Uri.parse('http://192.168.1.125/dataweb/update_user.php');
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
      if (normalized.contains(word)) {
        return true;
      }
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
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Container(color: Colors.white, height: 1.0),
        // ),
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
              );
            },
          ),
        ],
        backgroundColor: Colors.orange,
        // backgroundColor: Color(0xFFFFD54F),
      ),
      backgroundColor: Colors.orangeAccent,
      // backgroundColor: Color(0xFFFFE082),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 พื้นหลัง
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
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
                                  // TextField มีขนาดจำกัด
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
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "คุณต้องการออกจากระบบหรือไม่?",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
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
