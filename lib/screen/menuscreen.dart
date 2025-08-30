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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/icons/monkey64.png',
            width: 40,
            height: 40,
          ),
        ),
        title: Text("Games"),
        centerTitle: true,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0), // ความสูงของเส้น
        //   child: Container(
        //     color: Colors.white, // สีของเส้น
        //     height: 1.0,
        //   ),
        // ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.white, height: 1.0),
        ),
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
        backgroundColor: Color(0xFFE37400),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image/bg.png', fit: BoxFit.cover),
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
                    (dictionary, title) =>
                        Game1screen(dictionary: dictionary, title: title),
                  ),
                  buildGameButton(
                    "เกมจับคู่คำศัพท์",
                    Image.asset(
                      'assets/icons/match.png',
                      width: 90,
                      height: 90,
                    ),
                    Colors.orange[100]!,
                    (dictionary, title) =>
                        Game2screen(dictionary: dictionary, title: title),
                  ),
                  buildGameButton(
                    "เกมเติมคำ",
                    Image.asset('assets/icons/add.png', width: 90, height: 90),
                    Colors.deepPurpleAccent[100]!,
                    (dictionary, title) =>
                        Game3screen(dictionary: dictionary, title: title),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแปลง List<DicEntry> เป็น Map<String, List<String>>
  Map<String, List<String>> convertEntriesToMap(List<DicEntry> entries) {
    final map = <String, List<String>>{};
    for (var entry in entries) {
      map[entry.word] = [entry.meaning, entry.imageUrl];
    }
    return map;
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
          onPressed: () {
            SoundManager.playClick8BitSound();
            showCategoryDialog(screenBuilder);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(340, 135),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
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
                child: Text(
                  title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
      barrierDismissible: false,
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
                      Icons.directions_car,
                      Colors.yellow[100]!,
                      1,
                      screenBuilder,
                    ),
                    categoryButton(
                      "Animals",
                      "คำศัพท์เกี่ยวกับสัตว์",
                      Icons.pets,
                      Colors.orange[100]!,
                      2,
                      screenBuilder,
                    ),
                    categoryButton(
                      "House",
                      "คำศัพท์สิ่งของในบ้าน",
                      Icons.home,
                      Colors.green[100]!,
                      3,
                      screenBuilder,
                    ),
                    categoryButton(
                      "Sports",
                      "คำศัพท์เกี่ยวกับกีฬา",
                      Icons.sports_soccer,
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
    IconData icon,
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
          fixedSize: Size(280, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
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
