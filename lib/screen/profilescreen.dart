import 'package:app/management/game_data/game_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/management/sound/sound.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ProfilescreenState extends State<Profilescreen> {
  bool isEditing = false;
  TextEditingController _controller = TextEditingController(text: "User name");
  IconData selectedIcon = Icons.person;

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

  final List<Map<String, dynamic>> games = [
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("โปรไฟล์"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
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
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'กรอกชื่อไม่เกิน 20 ตัว',
                            ),
                            onSubmitted: (_) {
                              setState(() {
                                isEditing = false;
                              });
                            },
                          ),
                        )
                        : Text(
                          _controller.text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.check : Icons.edit,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
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
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "ออกจากเกม",
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
