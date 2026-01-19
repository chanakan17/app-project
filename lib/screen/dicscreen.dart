import 'package:app/management/dic.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/dictionary/dicallscreen.dart';
import 'package:app/screen/dictionary/dicaniscreen.dart';
import 'package:app/screen/dictionary/dichomescreen.dart';
import 'package:app/screen/dictionary/dicsportscreen.dart';
import 'package:app/screen/dictionary/translatescreen.dart';
import 'package:app/screen/game/game4screen.dart';
import 'package:flutter/material.dart';
// import 'package:app/screen/dictionary/translatescreen.dart';

class Dicscreen extends StatefulWidget {
  const Dicscreen({super.key});

  @override
  State<Dicscreen> createState() => _DicscreenState();
}

class _DicscreenState extends State<Dicscreen> {
  Map<String, List<String>> convertEntriesToMap(List<DicEntry> entries) {
    final map = <String, List<String>>{};
    for (var entry in entries) {
      map[entry.word] = [entry.meaning, entry.imageUrl];
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vocabulary",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 6,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      backgroundColor: Colors.amber[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            fixedSize: Size.fromHeight(100),
                            elevation: 6,
                            shadowColor: Colors.black.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            SoundManager.playClick8BitSound();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TranslateScreen(),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/image/translate.png',
                                width: 60,
                                height: 60,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Smart Translate",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "แปลคำศัพท์และประโยคทันที",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    buildGameButton(
                      "ฝึกพูดคำศัพท์ภาษาอังกฤษ",
                      "Speaking Test",
                      Image.asset(
                        'assets/icons/speak.png',
                        width: 60,
                        height: 60,
                      ),
                      (dictionary, title) =>
                          Game4screen(dictionary: dictionary, title: title),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Catehories",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildDicButton(
                            "Vehicles",
                            "คำศัพท์เกี่ยวกับยานพาหนะ",
                            Image.asset(
                              'assets/image/vehicle.png',
                              width: 90,
                              height: 90,
                            ),
                            Colors.yellow[100]!,
                            (context) => Dicallscreen(),
                          ),
                        ),
                        Expanded(
                          child: buildDicButton(
                            "Animals",
                            "คำศัพท์เกี่ยวกับสัตว์",
                            Image.asset(
                              'assets/image/animal.png',
                              width: 90,
                              height: 90,
                            ),
                            Colors.orange[100]!,
                            (context) => Dicaniscreen(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildDicButton(
                            "House",
                            "คำศัพท์สิ่งของในบ้าน",
                            Image.asset(
                              'assets/image/home.png',
                              width: 90,
                              height: 90,
                            ),
                            Colors.green[100]!,
                            (context) => Dichomescreen(),
                          ),
                        ),
                        Expanded(
                          child: buildDicButton(
                            "Sports",
                            "คำศัพท์เกี่ยวกับกีฬา",
                            Image.asset(
                              'assets/image/sport.png',
                              width: 90,
                              height: 90,
                            ),
                            Colors.red[100]!,
                            (context) => Dicsportscreen(),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 20),
                    // const Row(
                    //   children: [
                    //     Expanded(child: Divider()),
                    //     Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text('เร็วๆ นี้'),
                    //     ),
                    //     Expanded(child: Divider()),
                    //   ],
                    // ),
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
    Widget iconWidget,
    Color iconBackgroundColor,
    Widget Function(BuildContext) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SizedBox(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: iconBackgroundColor,
            fixedSize: Size.fromHeight(200),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              // side: BorderSide(
              //   color: Colors.orange, // สีของขอบ
              //   width: 3, // ความหนาของขอบ
              // ),
              borderRadius: BorderRadius.circular(20),
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGameButton(
    String title,
    String subtitle,
    Widget iconWidget,
    Widget Function(Map<String, List<String>>, String) screenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SizedBox(
        child: ElevatedButton(
          onPressed: () {
            SoundManager.playClick8BitSound();
            showCategoryDialog(screenBuilder);
          },
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.yellow,
            backgroundColor: Colors.white.withOpacity(0.8), //ความทึมแสง
            // backgroundColor: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.5),
            fixedSize: Size.fromHeight(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(width: 24),
                Container(
                  width: 200,
                  height: 90,
                  child: Row(
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
                              fontSize: 16,
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
      // barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("เลือกหมวดหมู่ที่ต้องการ"),
          // backgroundColor: Color.fromARGB(255, 236, 217, 159),
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
