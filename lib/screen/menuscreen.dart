import 'package:app/screen/game/game.dart';
import 'package:app/screen/game/game4screen.dart';
import 'package:app/screen/game/game5screen.dart';
import 'package:flutter/material.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/game/game1screen.dart';
import 'package:app/screen/game/game2screen.dart';
import 'package:app/screen/game/game3screen.dart';
import 'package:app/management/dic_service.dart'; // ✅ ใช้ DicService

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
    Color iconBackgroundColor,
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        child: ElevatedButton(
          onPressed: () {
            SoundManager.playClick8BitSound();
            showCategoryDialog(screenBuilder);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 6,
            shadowColor: Colors.black45,
            fixedSize: Size.fromHeight(120),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    color: iconBackgroundColor,
                    width: 90,
                    height: 90,
                    padding: EdgeInsets.all(10),
                    child: iconWidget,
                  ),
                ),
                SizedBox(width: 24),
                Container(
                  width: 200,
                  height: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
            final words = await DicService.fetchWords(categoryId: categoryId);
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
