import 'package:app/management/dic.dart';
import 'package:app/management/dicanimal.dart';
import 'package:app/management/dichome.dart';
import 'package:app/management/dicsp.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/game/game1screen.dart';
import 'package:app/screen/game/game2screen.dart';
import 'package:app/screen/game/game3screen.dart';
import 'package:flutter/material.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({super.key});

  @override
  State<Menuscreen> createState() => _MenuscreenState();
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

class _MenuscreenState extends State<Menuscreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/icons/monkey64.png',
            width: 40,
            height: 40,
          ),
        ),
        title: Text("เกม"),
        centerTitle: true,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0), // ความสูงของเส้น
        //   child: Container(
        //     color: Colors.grey, // สีของเส้น
        //     height: 1.0,
        //   ),
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/icons/star96.png',
              width: 40,
              height: 40,
            ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildGameButton(
                    "เกมทายคำศัพท์",
                    Image.asset(
                      'assets/icons/guess.png',
                      width: 90,
                      height: 90,
                    ),
                    Colors.blue[100]!,
                    (dict, title) =>
                        Game1screen(dictionary: dict, title: title),
                  ),
                  buildGameButton(
                    "เกมจับคู่คำศัพท์",
                    Image.asset(
                      'assets/icons/match.png',
                      width: 90,
                      height: 90,
                    ),
                    Colors.orange[100]!,
                    (dict, title) =>
                        Game2screen(dictionary: dict, title: title),
                  ),
                  buildGameButton(
                    "เกมเติมคำ",
                    Image.asset('assets/icons/add.png', width: 90, height: 90),
                    Colors.deepPurpleAccent[100]!,
                    (dict, title) =>
                        Game3screen(dictionary: dict, title: title),
                  ),

                  // buildGameButton(
                  //   "เกม4",
                  //   (dict) => Game4screen(dictionary: dict),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameButton(
    String title,
    Widget iconWidget,
    Color iconBackgroundColor,
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
      child: SizedBox(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(340, 135),
            shape: RoundedRectangleBorder(
              // side: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(25), // <-- ปรับความโค้งที่นี่
            ),
            // backgroundColor: Colors.grey[300],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  color: iconBackgroundColor,
                  width: 90,
                  height: 90,
                  padding: EdgeInsets.all(10),
                  child: iconWidget,
                ),
              ),

              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onPressed: () {
            SoundManager.playClick8BitSound();
            showCategoryDialog(screenBuilder);
          },
        ),
      ),
    );
  }

  void showCategoryDialog(
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("เลือกหมวดหมู่ที่ต้องการ"),
          actions: [
            SizedBox(
              width: 300,
              height: 400,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      categoryButton(
                        "คำศัพท์ยานพาหนะ",
                        "คำศัพท์เกี่ยวกับยานพาหนะและขนส่ง",
                        Icons.directions_car,
                        Colors.yellow[100]!,
                        Dic.entries,
                        screenBuilder,
                      ),
                      categoryButton(
                        "คำศัพท์สัตว์",
                        "คำศัพท์เกี่ยวกับสัตว์",
                        Icons.pets,
                        Colors.orange[100]!,
                        dicAnimal.entries,
                        screenBuilder,
                      ),
                      categoryButton(
                        "คำศัพท์บ้าน",
                        "่คำศัพท์สิ่งของในบ้าน",
                        Icons.home,
                        Colors.green[100]!,
                        dicHome.entries,
                        screenBuilder,
                      ),
                      categoryButton(
                        "คำศัพท์กีฬา",
                        "คำศัพท์เกี่ยวกับกีฬา",
                        Icons.sports_soccer,
                        Colors.red[100]!,
                        dicSport.entries,
                        screenBuilder,
                      ),
                    ],
                  ),
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
    IconData icon,
    Color iconBackgroundColor,
    dynamic dictionary,
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: ElevatedButton(
        onPressed: () {
          SoundManager.playClick8BitSound();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screenBuilder(dictionary, title),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          fixedSize: Size(280, 80),
          shape: RoundedRectangleBorder(
            // side: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          // backgroundColor: Colors.grey[300],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: iconBackgroundColor,
              radius: 30,
              child: Icon(icon, size: 40, color: Colors.blue),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
