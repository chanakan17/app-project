import 'package:app/management/sound/sound.dart';
import 'package:app/screen/dictionary/dicallscreen.dart';
import 'package:app/screen/dictionary/dicaniscreen.dart';
import 'package:app/screen/dictionary/dichomescreen.dart';
import 'package:app/screen/dictionary/dicsportscreen.dart';
import 'package:flutter/material.dart';
// import 'package:app/screen/dictionary/translatescreen.dart';

class Dicscreen extends StatefulWidget {
  const Dicscreen({super.key});

  @override
  State<Dicscreen> createState() => _DicscreenState();
}

class _DicscreenState extends State<Dicscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset('assets/icons/booka96.png', width: 40, height: 40),
        // ),
        title: Text(
          "Vocabulary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Container(color: Colors.white, height: 1.0),
        // ),
        backgroundColor: Color(0xFFFFD54F),
      ),
      backgroundColor: Color(0xFFFFE082),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
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
                      "Vehicles",
                      "คำศัพท์เกี่ยวกับยานพาหนะ",
                      Icons.directions_car,
                      Colors.yellow[100]!,
                      (context) => Dicallscreen(),
                    ),
                    buildDicButton(
                      "Animals",
                      "คำศัพท์เกี่ยวกับสัตว์",
                      Icons.pets,
                      Colors.orange[100]!,
                      (context) => Dicaniscreen(),
                    ),
                    buildDicButton(
                      "House",
                      "คำศัพท์สิ่งของในบ้าน",
                      Icons.home,
                      Colors.green[100]!,
                      (context) => Dichomescreen(),
                    ),
                    buildDicButton(
                      "Sports",
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
            backgroundColor: Colors.white.withOpacity(0.8),
            fixedSize: Size(360, 115),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.orange, // สีของขอบ
                width: 2, // ความหนาของขอบ
              ),
              borderRadius: BorderRadius.circular(25),
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
                radius: 45,
                child: Icon(icon, size: 60, color: Colors.blue),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(subtitle, style: TextStyle(fontSize: 18)),
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
