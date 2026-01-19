import 'dart:math';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    GameData.reset();
    typeDic = widget.dictionary;
    title = widget.title;
    availableKeys = typeDic.keys.toList(); // เก็บ key ทั้งหมด
    _getRandomEntries(); // เรียกสุ่มค่าเริ่มต้น
    _startGameTimer();
    GameData.gameName = 'เกมทายคำศัพท์';
    GameData.title = title;
  }

  void _startGameTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedTime = _formatTime(_stopwatch.elapsed);
      });
    });
  }

  void _endGame() {
    _stopwatch.stop();
    _timer?.cancel();

    GameData.playTimeMs = _stopwatch.elapsedMilliseconds;
    GameData.playTimeStr = _formatTime(_stopwatch.elapsed);

    final finalTime = _stopwatch.elapsedMilliseconds; // เวลาแบบ ms
    print("⏱ เวลาเล่นทั้งหมด: $finalTime ms");

    // ✅ เก็บเวลาในตัวแปร / DB / SharedPreferences / API
    // เช่น ส่งไปที่ GameData หรือ API
    // GameData.playTime = finalTime;
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = twoDigits(
      duration.inMilliseconds.remainder(1000) ~/ 10,
    );
    return "$minutes:$seconds:$milliseconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
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
              onPressed: () async {
                _endGame();
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
                await GameData.saveScoreToDB();
              },
              child: Text("ย้อนกลับไปยังเมนู"),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสุ่ม key และ value แบบไม่ซ้ำ
  late List<String> shuffledValues = [];

  void _getRandomEntries() {
    if (availableKeys.length < 4) {
      _endGame();
      _showFinishDialog();
      return;
    }

    var dic = typeDic;
    randomKeys.clear();
    randomValues.clear();

    Set<String> usedKeys = {};

    for (int i = 0; i < 4; i++) {
      String randomKey;
      do {
        randomKey = getRandomKey();
      } while (usedKeys.contains(randomKey));

      usedKeys.add(randomKey);
      randomKeys.add(randomKey);
      randomValues.add(getRandomValue(dic[randomKey]!));
    }

    availableKeys.remove(randomKeys[0]);

    correctValue = randomValues[0];

    /// 👇 shuffle ค่าที่นี่ครั้งเดียว
    shuffledValues = List.from(randomValues)..shuffle();

    setState(() {});
  }

  // ฟังก์ชันสุ่ม key จาก Map (แบบไม่ซ้ำ)
  String getRandomKey() {
    var random = Random();
    return availableKeys[random.nextInt(availableKeys.length)];
  }

  // ฟังก์ชันสุ่ม value จาก List<String> ที่ตรงกับ key
  // String getRandomValue(List<String> values) {
  //   var random = Random();
  //   return values[random.nextInt(values.length)];
  // }
  String getRandomValue(List<String> values) {
    return values.isNotEmpty ? values[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "เกมทายคำศัพท์",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black26, height: 2.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              _stopwatch.stop();
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
                          backgroundColor: Colors.red,
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
                        child: Text(
                          "ออกจากเกม",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          _stopwatch.start();
                          SoundManager.playClickSound();
                          Navigator.of(context).pop();
                        },
                        child: Text("อยู่ต่อ"),
                      ),
                    ],
                  );
                },
                barrierDismissible: false,
              );
            },
          ),
        ],
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.amber[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 24),
                          SizedBox(width: 4), // ระยะห่างระหว่างไอคอนกับเวลา
                          Text("$_elapsedTime", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.end,
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
                          padding: const EdgeInsets.fromLTRB(8, 80, 8, 8),
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
                                          _stopwatch.stop();
                                        } else {
                                          scoredis--;
                                          SoundManager.playCheckfalseSound();
                                          _stopwatch.stop();
                                        }

                                        if (scoredis < 1) {
                                          _endGame();
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
                                                                _stopwatch
                                                                    .start();
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
                                                                _stopwatch
                                                                    .start();
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
                                              255,
                                              162,
                                              0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color.fromARGB(
                                                  255,
                                                  248,
                                                  120,
                                                  0,
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
