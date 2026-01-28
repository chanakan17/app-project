import 'package:app/screen/game/game.dart';
import 'package:app/screen/game/game4screen.dart';
import 'package:app/screen/game/game5screen.dart';
import 'package:flutter/material.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/game/game1screen.dart';
import 'package:app/screen/game/game2screen.dart';
import 'package:app/screen/game/game3screen.dart';
import 'package:app/management/dic_service30.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({super.key});

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: MyBottomCurveClipper(),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade300, Colors.orange.shade800],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // SizedBox(height: 10),
                          Text(
                            "Let's Play!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAEAD1),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Challenge Mode",
                    style: TextStyle(
                      color: Colors.brown[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildGameButton(
                    "เกมทายคำศัพท์",
                    "Guessing Game",
                    Image.asset(
                      'assets/icons/guess.png',
                      width: 90,
                      height: 90,
                    ),
                    Colors.orange[100]!,
                    (dictionary, title) =>
                        Game1screen(dictionary: dictionary, title: title),
                  ),
                  buildGameButton(
                    "เกมจับคู่คำศัพท์",
                    "Matching Game",
                    Image.asset(
                      'assets/icons/match.png',
                      width: 90,
                      height: 90,
                    ),
                    Colors.blue[100]!,
                    (dictionary, title) =>
                        Game2screen(dictionary: dictionary, title: title),
                  ),
                  buildGameButton(
                    "เกมเติมคำ",
                    "Completion Game",
                    Image.asset('assets/icons/add.png', width: 90, height: 90),
                    Colors.deepPurpleAccent[100]!,
                    (dictionary, title) =>
                        Game3screen(dictionary: dictionary, title: title),
                  ),
                  buildGameButton(
                    "เกมทายรูปภาพ",
                    "Picture Game",
                    Image.asset('assets/icons/pic.png', width: 90, height: 90),
                    Colors.green[100]!,
                    (dictionary, title) =>
                        Game5screen(dictionary: dictionary, title: title),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> convertEntriesToMap(List<DicEntry> entries) {
    final map = <String, List<String>>{};
    for (var entry in entries) {
      map[entry.word] = [entry.meaning, entry.imageUrl];
    }
    return map;
  }

  Widget buildGameButton(
    String title,
    String subtitle,
    Widget iconWidget,
    Color
    baseColor, // เปลี่ยนชื่อจาก iconBackgroundColor เป็น baseColor เพื่อสื่อความหมาย
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, baseColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              SoundManager.playClick8BitSound();
              showCategoryDialog(screenBuilder);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // ส่วน Icon ที่มีพื้นหลังซ้อน
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: iconWidget,
                  ),
                  SizedBox(width: 20),
                  // ส่วนข้อความ
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color:
                                Colors
                                    .brown[800], // ใช้สีเข้มเพื่อให้ตัดกับพื้นหลัง
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.brown[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ลูกศรบอกทาง
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.brown[300],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showCategoryDialog(
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("เลือกหมวดหมู่ที่ต้องการ"),
          actions: [
            SizedBox(
              width: 300,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    categoryButton(
                      "Vehicles",
                      "คำศัพท์เกี่ยวกับยานพาหนะ",
                      Image.asset(
                        'assets/image/vehicle.png',
                        width: 48,
                        height: 48,
                      ),
                      Colors.yellow[100]!,
                      1,
                      screenBuilder,
                    ),
                    categoryButton(
                      "Animals",
                      "คำศัพท์เกี่ยวกับสัตว์",
                      Image.asset(
                        'assets/image/animal.png',
                        width: 48,
                        height: 48,
                      ),
                      Colors.orange[100]!,
                      2,
                      screenBuilder,
                    ),
                    categoryButton(
                      "House",
                      "คำศัพท์สิ่งของในบ้าน",
                      Image.asset(
                        'assets/image/home.png',
                        width: 48,
                        height: 48,
                      ),
                      Colors.green[100]!,
                      3,
                      screenBuilder,
                    ),
                    categoryButton(
                      "Sports",
                      "คำศัพท์เกี่ยวกับกีฬา",
                      Image.asset(
                        'assets/image/sport.png',
                        width: 48,
                        height: 48,
                      ),
                      Colors.red[100]!,
                      4,
                      screenBuilder,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget categoryButton(
    String title,
    String subtitle,
    Widget iconWidget,
    Color iconBackgroundColor,
    int categoryId,
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () async {
          SoundManager.playClick8BitSound();
          Navigator.of(context).pop();

          try {
            final words = await DicService.fetchRandomWords(
              categoryId: categoryId,
              count: 28,
            );
            final dictionaryMap = convertEntriesToMap(words);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => screenBuilder(dictionaryMap, title),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดคำศัพท์')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: iconBackgroundColor,
          fixedSize: Size(280, 80),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // side: BorderSide(color: Colors.orange, width: 2),
          ),
        ),
        child: Row(
          children: [
            iconWidget,
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyBottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
