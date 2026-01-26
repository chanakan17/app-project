import 'dart:math';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Game2screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;
  final String title;

  const Game2screen({super.key, required this.dictionary, required this.title});
  @override
  State<Game2screen> createState() => _Game2screenState();
}

late Map<String, List<String>> typeDic;

class _Game2screenState extends State<Game2screen> {
  List<String> randomKeys = [];
  List<String> randomValues = [];
  List<String> shuffledValues = [];
  Map<String, String?> userAnswers = {};
  int score = 0;
  int scoredis = 5;
  late List<String> availableKeys;
  Set<String> usedValues = {};
  Map<String, bool>? answerCorrectness;
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
    availableKeys = typeDic.keys.toList();
    _getRandomEntries();
    _startGameTimer();
    GameData.gameName = 'เกมจับคู่คำศัพท์';
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

  void _getRandomEntries() async {
    if (availableKeys.length < 4) {
      _endGame();
      GameData.updateTopScore();
      await GameData.saveScoreToDB();
      _showFinishDialog();
      return;
    }

    randomKeys.clear();
    randomValues.clear();
    usedValues.clear();

    Set<String> usedKeys = {};
    for (int i = 0; i < 4; i++) {
      String randomKey;
      do {
        randomKey = getRandomKey();
      } while (usedKeys.contains(randomKey));

      usedKeys.add(randomKey);
      randomKeys.add(randomKey);
      randomValues.add(getRandomValue(typeDic[randomKey]!));
    }

    availableKeys.removeWhere((key) => randomKeys.contains(key));

    userAnswers = {for (var key in randomKeys) key: null};

    shuffledValues = List.from(randomValues)..shuffle();

    setState(() {});
  }

  String getRandomKey() {
    var random = Random();
    return availableKeys[random.nextInt(availableKeys.length)];
  }

  String getRandomValue(List<String> values) {
    return values.isNotEmpty ? values[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "เกมจับคู่คำศัพท์",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black26, height: 2.0),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 40,
            onPressed: () {
              _stopwatch.stop();
              SoundManager.playClickSound();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "คุณต้องการออกจากเกมหรือไม่?",
                      style: TextStyle(fontSize: 21),
                    ),
                    content: Text("คุณต้องการออกจากเกมหรือไม่😭"),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          _endGame();
                          GameData.updateTopScore();
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
                          await GameData.saveScoreToDB();
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
      ),
      backgroundColor: Colors.amber[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 40),
            child: Column(
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
                Row(
                  children: [
                    Image.asset(
                      'assets/image/monkey.png',
                      width: 100,
                      height: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                      child: Text(
                        "จับคู่คำศัพท์ต่อไปนี้",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                // คำศัพท์และกล่องคำแปลด้านขวา
                Expanded(
                  child: ListView.builder(
                    itemCount: randomKeys.length,
                    itemBuilder: (context, index) {
                      final key = randomKeys[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ด้านซ้าย: คำศัพท์
                              Container(
                                width: 150,
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),

                              // ด้านขวา: DragTarget
                              DragTarget<String>(
                                onWillAccept: (_) => true,
                                onAccept: (data) {
                                  setState(() {
                                    // ลบคำเดิม (ถ้ามี) จาก usedValues
                                    if (userAnswers[key] != null) {
                                      usedValues.remove(userAnswers[key]);
                                    }
                                    answerCorrectness = null;
                                    // อัปเดตเป็นคำใหม่
                                    userAnswers[key] = data;
                                    usedValues.add(data);
                                  });
                                },
                                builder: (
                                  context,
                                  candidateData,
                                  rejectedData,
                                ) {
                                  final answer = userAnswers[key];

                                  return Draggable<String>(
                                    data: answer ?? '',
                                    feedback: Material(
                                      child: Chip(
                                        label: Text(
                                          answer ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      width: 150,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300],
                                      ),
                                      child: Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    onDragStarted: () {
                                      if (answer != null) {
                                        setState(() {
                                          usedValues.remove(answer);
                                          userAnswers[key] = null;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(8),
                                        color: () {
                                          if (answer != null &&
                                              answerCorrectness != null) {
                                            return answerCorrectness![key] ==
                                                    true
                                                ? Colors.green[100]
                                                : Colors.red[100];
                                          } else if (answer != null) {
                                            return Colors.orange[100];
                                          }
                                          return null;
                                        }(),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          answer ?? '',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  "เลือกคำไว้ในช่องให้ถูกต้อง",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),

                // คำแปลที่ยังไม่ได้วาง
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      shuffledValues.map((val) {
                        bool isUsed = usedValues.contains(val);
                        return isUsed
                            ? SizedBox(width: 80, height: 40)
                            : Draggable<String>(
                              data: val,
                              feedback: Material(
                                child: Chip(
                                  label: Text(
                                    val,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                              childWhenDragging: Chip(
                                label: Text(
                                  val,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                backgroundColor: Colors.grey[300],
                              ),
                              child: Chip(
                                label: Text(
                                  val,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                      }).toList(),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    int matched = 0;
                    Map<String, bool> correctness = {};

                    userAnswers.forEach((key, val) {
                      bool isCorrect =
                          val != null && typeDic[key]!.contains(val);
                      correctness[key] = isCorrect;
                      if (isCorrect) matched++;
                    });

                    setState(() {
                      answerCorrectness = correctness;
                    });

                    if (matched == userAnswers.length) {
                      // score++;
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

                    if (matched == userAnswers.length) {
                      List<String> successMessages = [
                        "ถูกต้องแล้ว",
                        "เยี่ยมมาก!",
                        "เก่งสุดๆ",
                        "เฉียบคม!",
                        "แม่นยำมาก",
                        "ถูกต้องนะค้าบ",
                      ];
                      String randomMessage =
                          successMessages[Random().nextInt(
                            successMessages.length,
                          )];
                      showModalBottomSheet(
                        context: context,
                        isDismissible: false, // ไม่ให้ปิดเมื่อแตะนอกพื้นที่
                        enableDrag: false, // ไม่ให้ลาก bottom sheet ออกได้
                        isScrollControlled: true, // ควบคุมการ scroll ของเนื้อหา
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // <-- ทำให้ไม่โค้งเลย
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          color: Color(0xFFFFA000),
                                          size: 40, // ขนาด
                                        ),
                                        Text(
                                          randomMessage,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Color(0xFFFFA000),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "คุณจับคู่ถูก $matched/${userAnswers.length} ข้อ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFFFFA000),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // ปิด dialog
                                          setState(() {
                                            score += matched;
                                            _stopwatch.start();
                                            _getRandomEntries();
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 320,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFCA28),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFFFFA000),
                                                    width: 4,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'ไปข้อต่อไป',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
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
                      List<String> wrongMessages = [
                        "ผิดจร้าาา",
                        "ว้า... ผิดนะ",
                        "ยังไม่ใช่นะครับ",
                        "ลองใหม่อีกทีนะ",
                        "เกือบถูกแล้วเชียว",
                        "โอ๊ะโอ... ไม่ใช่นะ",
                      ];

                      String randomWrongMessage =
                          wrongMessages[Random().nextInt(wrongMessages.length)];

                      showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        enableDrag: false,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // <-- ทำให้ไม่โค้งเลย
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.close,
                                          color: Colors.red, // สีแดง
                                          size: 40, // ขนาดใหญ่
                                        ),
                                        Text(
                                          randomWrongMessage,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "คุณจับคู่ถูก $matched/${userAnswers.length} ข้อ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            score += matched;
                                            _stopwatch.start();
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
                                                    BorderRadius.circular(25),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      221,
                                                      15,
                                                      0,
                                                    ),
                                                    width: 4,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'ไปข้อต่อไป',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
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
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 320,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(25),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFFFA000),
                              width: 4,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'เสร็จสิ้น',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
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
