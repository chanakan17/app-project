import 'dart:math';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';

class Game1screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;
  final String title;

  const Game1screen({super.key, required this.dictionary, required this.title});
  @override
  State<Game1screen> createState() => _Game1screenState();
}

late Map<String, List<String>> typeDic;

class _Game1screenState extends State<Game1screen> {
  List<String> randomKeys = [];
  List<String> randomValues = [];
  String? correctValue;
  int score = 0;
  int scoredis = 5;
  late List<String> availableKeys; // ลิสต์ของ key ที่สามารถสุ่มได้
  late String title;

  @override
  void initState() {
    super.initState();
    GameData.reset();
    typeDic = widget.dictionary;
    title = widget.title;
    availableKeys = typeDic.keys.toList(); // เก็บ key ทั้งหมด
    _getRandomEntries(); // เรียกสุ่มค่าเริ่มต้น

    GameData.gameName = 'เกมทายคำศัพท์';
    GameData.title = title;
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("จบเกมแล้ว!"),
          content: Text("คุณทำคะแนนได้ทั้งหมด $score คะแนน"),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                GameData.updateTopScore();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen(initialTabIndex: 0);
                    },
                  ),
                );
              },
              child: Text("ย้อนกลับไปยังเมนู"),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสุ่ม key และ value แบบไม่ซ้ำ
  void _getRandomEntries() {
    if (availableKeys.length < 4) {
      // กรณีมี key ไม่พอสุ่ม (จบเกม)
      _showFinishDialog();
      return;
    }

    var dic = typeDic;
    randomKeys.clear();
    randomValues.clear();

    Set<String> usedKeys = {};

    // สุ่ม 4 คำ โดยไม่ให้ซ้ำ
    for (int i = 0; i < 4; i++) {
      String randomKey;
      do {
        randomKey = getRandomKey();
      } while (usedKeys.contains(randomKey));

      usedKeys.add(randomKey);
      randomKeys.add(randomKey);
      randomValues.add(getRandomValue(dic[randomKey]!));
    }

    // ลบ key แรกออกจาก availableKeys เพื่อไม่ให้ซ้ำในรอบต่อไป
    availableKeys.remove(randomKeys[0]);

    correctValue = randomValues[0];
    setState(() {});
  }

  // ฟังก์ชันสุ่ม key จาก Map (แบบไม่ซ้ำ)
  String getRandomKey() {
    var random = Random();
    return availableKeys[random.nextInt(availableKeys.length)];
  }

  // ฟังก์ชันสุ่ม value จาก List<String> ที่ตรงกับ key
  String getRandomValue(List<String> values) {
    var random = Random();
    return values[random.nextInt(values.length)];
  }

  @override
  Widget build(BuildContext context) {
    // สลับตำแหน่งของ randomValues ในการแสดงผล แต่ไม่ส่งผลต่อ correctValue
    List<String> shuffledValues = List.from(randomValues);
    shuffledValues.shuffle();
    return Scaffold(
      appBar: AppBar(
        title: Text("เกมทายคำศัพท์"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.white, height: 1.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              // แสดง AlertDialog เมื่อกดปุ่มปิด
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "คุณต้องการออกจากเกมหรือไม่?",
                      style: TextStyle(fontSize: 21),
                    ),
                    content: Text("หากคุณออกจากเกม ข้อมูลจะไม่ได้รับการบันทึก"),
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
                        child: Text("อยู่ต่อ"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          SoundManager.playClickSound();
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen(initialTabIndex: 0);
                              },
                            ),
                          );
                        },
                        child: Text("ออกจากเกม"),
                      ),
                    ],
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
          Image.asset('assets/image/bg.png', fit: BoxFit.cover),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'คะแนน: $score',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/banana.png',
                            width: 35,
                            height: 35,
                          ),
                          Text('$scoredis', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: Text(
                                "เลือกคำให้ถูกต้อง ?",
                                style: TextStyle(fontSize: 23),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/image/monkey.png',
                                width: 180,
                                height: 180,
                              ),
                              Container(
                                width: 180,
                                height: 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        5,
                                        15,
                                        0,
                                        0,
                                      ),
                                      child: Text(
                                        '${randomKeys[0]}',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ใช้ Wrap หรือ Row เพื่อจัดปุ่มในแนวนอน
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                          child: Column(
                            spacing:
                                10.0, // ระยะห่างระหว่างปุ่ม// ระยะห่างแนวตั้ง
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < randomKeys.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (shuffledValues[i] == correctValue) {
                                          score++;
                                          GameData.score = score;
                                          SoundManager.playChecktrueSound();
                                        } else {
                                          scoredis--;
                                          SoundManager.playCheckfalseSound();
                                        }

                                        if (scoredis < 1) {
                                          _showFinishDialog();
                                          return;
                                        }

                                        // เช็คว่า คำแปลที่เลือกตรงกับคำแปลที่ถูกต้องหรือไม่
                                        if (shuffledValues[i] == correctValue) {
                                          showModalBottomSheet(
                                            context: context,
                                            isDismissible:
                                                false, // ไม่ให้ปิดเมื่อแตะนอกพื้นที่
                                            enableDrag:
                                                false, // ไม่ให้ลาก bottom sheet ออกได้
                                            isScrollControlled:
                                                true, // ควบคุมการ scroll ของเนื้อหา
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .zero, // <-- ทำให้ไม่โค้งเลย
                                            ),
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors
                                                                      .green, // สีเขียว
                                                              size: 40, // ขนาด
                                                            ),
                                                            Text(
                                                              "ถูกต้องแล้ว",
                                                              style: TextStyle(
                                                                fontSize: 25,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Text(
                                                          "${randomKeys[0]} --> ${correctValue}",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                context,
                                                              ).pop(); // ปิด dialog
                                                              setState(() {
                                                                _getRandomEntries();
                                                              });
                                                            },
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  width: 320,
                                                                  height: 48,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(
                                                                      0xFF4CD200,
                                                                    ), // สีเขียวหลัก
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          25,
                                                                        ),
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color: Color(
                                                                          0xFF3ABA00,
                                                                        ),
                                                                        width:
                                                                            4,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    'ไปข้อต่อไป',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          showModalBottomSheet(
                                            context: context,
                                            isDismissible: false,
                                            enableDrag: false,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .zero, // <-- ทำให้ไม่โค้งเลย
                                            ),
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors
                                                                      .red, // สีแดง
                                                              size:
                                                                  40, // ขนาดใหญ่
                                                            ),
                                                            Text(
                                                              "ผิดจร้าาา",
                                                              style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Text(
                                                          "${randomKeys[0]} --> ${correctValue}",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              setState(() {
                                                                _getRandomEntries();
                                                              });
                                                            },
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  width: 320,
                                                                  height: 48,
                                                                  decoration: BoxDecoration(
                                                                    color: Color.fromARGB(
                                                                      255,
                                                                      255,
                                                                      81,
                                                                      81,
                                                                    ), // สีเขียวหลัก
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          25,
                                                                        ),
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          221,
                                                                          15,
                                                                          0,
                                                                        ),
                                                                        width:
                                                                            4,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    'ไปข้อต่อไป',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 320,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              59,
                                              134,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color.fromARGB(
                                                  255,
                                                  6,
                                                  73,
                                                  181,
                                                ),
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${shuffledValues[i]}",
                                            style: TextStyle(
                                              fontSize: 20,
                                              // fontWeight: FontWeight.bold,
                                              // color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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
