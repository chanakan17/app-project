import 'package:app/management/sound/sound.dart';
import 'package:app/screen/dictionary/dicallscreen.dart';
import 'package:app/screen/dictionary/dicaniscreen.dart';
import 'package:app/screen/dictionary/dichomescreen.dart';
import 'package:app/screen/dictionary/dicsportscreen.dart';
import 'package:app/screen/dictionary/translatescreen.dart';
import 'package:flutter/material.dart';

class Dicscreen extends StatefulWidget {
  const Dicscreen({super.key});

  @override
  State<Dicscreen> createState() => _DicscreenState();
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

class _DicscreenState extends State<Dicscreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset('assets/icons/booka96.png', width: 40, height: 40),
        // ),
        title: Text("Vocabulary"),
        centerTitle: true,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Container(color: Colors.grey, height: 1.0),
        // ),
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
            padding: const EdgeInsets.fromLTRB(8, 50, 8, 50),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // buildDicButton(
                    //   "translate",
                    //   "แปลคำศัพท์และประโยค",
                    //   Icons.library_books,
                    //   Colors.purple[100]!,
                    //   (context) => TranslateScreen(),
                    // ),
                    buildDicButton(
                      "คำศัพท์ยานพาหนะ",
                      "คำศัพท์เกี่ยวกับยานพาหนะและขนส่ง",
                      Icons.directions_car,
                      Colors.yellow[100]!,
                      (context) => Dicallscreen(),
                    ),
                    buildDicButton(
                      "คำศัพท์สัตว์",
                      "คำศัพท์เกี่ยวกับสัตว์",
                      Icons.pets,
                      Colors.orange[100]!,
                      (context) => Dicaniscreen(),
                    ),
                    buildDicButton(
                      "คำศัพท์บ้าน",
                      "่คำศัพท์สิ่งของในบ้าน",
                      Icons.home,
                      Colors.green[100]!,
                      (context) => Dichomescreen(),
                    ),
                    buildDicButton(
                      "คำศัพท์กีฬา",
                      "คำศัพท์เกี่ยวกับกีฬา",
                      Icons.sports_soccer,
                      Colors.red[100]!,
                      (context) => Dicsportscreen(),
                    ),
                    SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('เร็วๆ นี้'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDicButton(
    String title,
    String subtitle,
    IconData icon,
    Color iconBackgroundColor,
    Widget Function(BuildContext) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: SizedBox(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(300, 80),
            shape: RoundedRectangleBorder(
              // side: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            // backgroundColor: Colors.grey[300],
          ),
          onPressed: () {
            SoundManager.playClick8BitSound();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => screenBuilder(context)),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: iconBackgroundColor,
                radius: 30,
                child: Icon(icon, size: 40, color: Colors.blue),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(subtitle, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
