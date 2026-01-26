import 'dart:math';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class Game3screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;
  final String title;

  const Game3screen({super.key, required this.dictionary, required this.title});

  @override
  State<Game3screen> createState() => _Game3screenState();
}

late Map<String, List<String>> typeDic;

class _Game3screenState extends State<Game3screen> {
  List<String> randomKeys = [];
  List<String> randomValues = []; // เก็บ URL รูปภาพ
  String currentMeaning =
      ""; // ตัวแปรใหม่: เก็บคำแปลภาษาไทย (สำหรับแสดงใน Dialog)
  List<String> maskedCharacters = [];
  List<TextEditingController> controllers = [];
  int score = 0;
  int scoredis = 5;
  late List<String> availableKeys;
  List<FocusNode> focusNodes = [];
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
    GameData.gameName = 'เกมเติมคำ';
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

  void _getRandomEntries() {
    if (availableKeys.isEmpty) {
      _endGame();
      _showFinishDialog();
      return;
    }

    randomKeys.clear();
    randomValues.clear();

    String randomKey = getRandomKey();
    randomKeys.add(randomKey);

    // ดึงข้อมูล Value ทั้งหมด
    List<String> values = typeDic[randomKey]!;

    // index 0 คือคำแปล/คำใบ้, index 1 คือ URL รูปภาพ
    currentMeaning =
        values.isNotEmpty ? values[0] : ""; // เก็บคำแปลไว้ใช้ใน Dialog
    String imageUrl =
        values.length > 1
            ? values[1]
            : (values.isNotEmpty ? values[0] : ""); // เก็บ URL

    randomValues.add(imageUrl);

    availableKeys.remove(randomKey);

    _maskWord(randomKey);
    setState(() {});
  }

  String getRandomKey() {
    var random = Random();
    return availableKeys[random.nextInt(availableKeys.length)];
  }

  void _maskWord(String word) {
    maskedCharacters = word.split('');
    int hideCount = (word.length / 2).ceil();

    Set<int> hiddenIndices = {};
    Random random = Random();
    while (hiddenIndices.length < hideCount) {
      hiddenIndices.add(random.nextInt(word.length));
    }

    controllers = List.generate(word.length, (i) => TextEditingController());
    focusNodes = List.generate(word.length, (i) => FocusNode());

    for (int i = 0; i < word.length; i++) {
      if (hiddenIndices.contains(i)) {
        maskedCharacters[i] = '_';
      } else {
        controllers[i].text = word[i];
      }
    }
  }

  void _checkAnswer() {
    String userInput = '';
    for (int i = 0; i < controllers.length; i++) {
      userInput += controllers[i].text;
    }
    setState(() {
      if (userInput.toLowerCase() == randomKeys[0].toLowerCase()) {
        score++;
        GameData.score = score;
        _stopwatch.stop();
      } else {
        scoredis--;
        _stopwatch.stop();
      }

      if (scoredis < 1) {
        _endGame();
        _showFinishDialog();
        return;
      }

      if (userInput.toLowerCase() == randomKeys[0].toLowerCase()) {
        List<String> successMessages = [
          "ถูกต้องแล้ว",
          "เยี่ยมมาก!",
          "เก่งสุดๆ",
          "เฉียบคม!",
          "แม่นยำมาก",
          "ถูกต้องนะค้าบ",
        ];
        String randomMessage =
            successMessages[Random().nextInt(successMessages.length)];
        SoundManager.playChecktrueSound();
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                          Icon(Icons.check, color: Color(0xFFFFA000), size: 40),
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
                        // ใช้ currentMeaning แทน randomValues[0] เพื่อแสดงคำแปลภาษาไทยแทน URL
                        "$currentMeaning --> ${randomKeys[0]}",
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
                            Navigator.of(context).pop();
                            setState(() {
                              _getRandomEntries();
                              _stopwatch.start();
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 320,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFCA28),
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
        SoundManager.playCheckfalseSound();
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                          Icon(Icons.close, color: Colors.red, size: 40),
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
                        // ใช้ currentMeaning แทน เพื่อแสดงคำแปลภาษาไทย
                        "$currentMeaning --> ${randomKeys[0]}",
                        style: TextStyle(fontSize: 20, color: Colors.red),
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
                              _getRandomEntries();
                              _stopwatch.start();
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 320,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 81, 81),
                                  borderRadius: BorderRadius.circular(25),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "เกมเติมคำ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black26, height: 2.0),
        ),
        backgroundColor: Colors.orange,
        actions: <Widget>[
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
                    actions: <Widget>[
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
            child: Center(
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
                            SizedBox(width: 4),
                            Text(
                              "$_elapsedTime",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Row(
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
                                Text(
                                  '$scoredis',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "เติมคำในช่องว่างให้ถูกต้อง",
                          style: TextStyle(fontSize: 23),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                            child: Column(
                              // เปลี่ยน Row เป็น Column เพื่อจัดเรียงแนวตั้ง
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  child: Image.network(
                                    randomValues[0], // URL รูปภาพ
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(child: Icon(Icons.error));
                                    },
                                  ),
                                ),
                                SizedBox(height: 15), // ระยะห่าง
                                // --- ส่วนที่เพิ่ม: แสดงคำศัพท์ภาษาอังกฤษ ---
                                Text(
                                  currentMeaning, // แสดงคำศัพท์ภาษาอังกฤษ
                                  style: TextStyle(
                                    fontSize: 32,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing:
                                        2.0, // เพิ่มระยะห่างตัวอักษรให้อ่านง่าย
                                  ),
                                ),
                                // ---------------------------------------
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(maskedCharacters.length, (
                              index,
                            ) {
                              if (maskedCharacters[index] == '_') {
                                return SizedBox(
                                  width: 40,
                                  child: Focus(
                                    child: TextField(
                                      controller: controllers[index],
                                      focusNode: focusNodes[index],
                                      maxLength: 1,
                                      decoration: InputDecoration(
                                        counterText: '',
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          int nextIndex = index + 1;
                                          while (nextIndex <
                                                  maskedCharacters.length &&
                                              maskedCharacters[nextIndex] !=
                                                  '_') {
                                            nextIndex++;
                                          }
                                          if (nextIndex <
                                              maskedCharacters.length) {
                                            FocusScope.of(context).requestFocus(
                                              focusNodes[nextIndex],
                                            );
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }
                                        }
                                      },
                                    ),
                                    onKey: (FocusNode node, RawKeyEvent event) {
                                      if (event is RawKeyDownEvent &&
                                          event.logicalKey ==
                                              LogicalKeyboardKey.backspace &&
                                          controllers[index].text.isEmpty) {
                                        int prevIndex = index - 1;
                                        while (prevIndex >= 0 &&
                                            maskedCharacters[prevIndex] !=
                                                '_') {
                                          prevIndex--;
                                        }
                                        if (prevIndex >= 0) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(focusNodes[prevIndex]);
                                          controllers[prevIndex].text = '';
                                        }
                                        return KeyEventResult.handled;
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                  ),
                                );
                              } else {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                  child: Text(
                                    maskedCharacters[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _checkAnswer();
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
          ),
        ],
      ),
    );
  }
}
