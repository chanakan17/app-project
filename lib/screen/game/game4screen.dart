import 'dart:async';
import 'dart:math';
import 'package:app/management/game_data/game_data.dart';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class Game4screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;
  final String title;

  const Game4screen({super.key, required this.dictionary, required this.title});

  @override
  State<Game4screen> createState() => _Game4screenState();
}

late Map<String, List<String>> typeDic;

class _Game4screenState extends State<Game4screen> {
  late List<String> availableKeys;
  late String currentKey;
  late String correctValue;
  int score = 0;
  int scoredis = 5;
  String _spokenText = "";
  String _feedback = "";
  bool _isListening = false;

  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  Timer? _silenceTimer;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    typeDic = widget.dictionary;
    availableKeys = typeDic.keys.toList();
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();

    _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    _loadNextQuestion();
    _startGameTimer();

    GameData.reset();
    GameData.gameName = 'เกมพูดคำศัพท์';
    GameData.title = widget.title;
  }

  void _startGameTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
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

  void _loadNextQuestion() {
    if (availableKeys.isEmpty) {
      _endGame();
      _showFinishDialog();
      return;
    }

    var rand = Random();
    currentKey = availableKeys[rand.nextInt(availableKeys.length)];
    var values = typeDic[currentKey]!;
    correctValue = values[rand.nextInt(values.length)];
    _spokenText = "";
    _feedback = "";
    setState(() {});
  }

  Future<void> _speakWord() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(currentKey);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == "notListening") {
            setState(() => _isListening = false);
            _silenceTimer?.cancel();
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: 'en_US', // ปรับให้ตรงกับภาษา
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords.trim();
            });

            // จับเวลาหยุดฟังอัตโนมัติ
            _silenceTimer?.cancel();
            _silenceTimer = Timer(Duration(milliseconds: 1200), () {
              _speech.stop();
              setState(() => _isListening = false);
              _checkAnswer();
            });
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          listenFor: Duration(minutes: 5),
          pauseFor: Duration(seconds: 5),
        );
      } else {
        print("Speech recognition not available");
      }
    } else {
      _speech.stop();
      _silenceTimer?.cancel();
      setState(() => _isListening = false);
    }
  }

  void _checkAnswer() {
    // ลบช่องว่างและเปรียบเทียบตัวพิมพ์เล็ก
    String userWord = _spokenText.replaceAll(' ', '').toLowerCase();
    String correctWord = currentKey.replaceAll(' ', '').toLowerCase();

    bool isCorrect = userWord == correctWord;

    setState(() {
      _feedback =
          isCorrect ? "✅ ถูกต้อง! ได้คะแนน +1" : "❌ ผิด! คำตอบคือ: $currentKey";
    });

    if (isCorrect) {
      score++;
      GameData.score = score;
      SoundManager.playChecktrueSound();
    } else {
      scoredis--;
      SoundManager.playCheckfalseSound();
    }

    if (scoredis < 1) {
      _endGame();
      _showFinishDialog();
      return;
    }

    // แสดงผลลัพธ์ใน modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResultModal(isCorrect, [
        TextSpan(
          text: currentKey,
          style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
        ),
      ]);
    });
  }

  void _showResultModal(bool isCorrect, List<TextSpan> textSpans) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 40,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isCorrect ? "ถูกต้องแล้ว" : "ผิดจร้าาา",
                    style: TextStyle(
                      fontSize: 25,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(children: textSpans),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text("คำแปล: $correctValue", style: TextStyle(fontSize: 18)),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadNextQuestion();
                  },
                  child: Text("ไปข้อต่อไป"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("จบเกมแล้ว!"),
          content: Text("คุณทำคะแนนได้ทั้งหมด $score คะแนน"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                _endGame();
                GameData.updateTopScore();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(initialTabIndex: 0),
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

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เกมพูดคำศัพท์"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Text(
                        "พูดคำศัพท์ต่อไปนี้",
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/image/monkey.png',
                        width: 180,
                        height: 180,
                      ),
                      Expanded(
                        child: CustomPaint(
                          painter: BubblePainter(),
                          child: Container(
                            width: 200,
                            height: 80,
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _speakWord,
                                    icon: Icon(Icons.volume_up, size: 25),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: FittedBox(
                                      child: Text(
                                        currentKey,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    fixedSize: Size(280, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onPressed: () {
                    print("Button pressed"); // debug
                    _listen();
                  },
                  icon: Icon(Icons.mic),
                  label: Text(_isListening ? "กำลังฟัง..." : "พูดคำศัพท์"),
                ),
                SizedBox(height: 20),
                Text("คุณพูดว่า: $_spokenText", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text(
                  _feedback,
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // สร้าง LinearGradient สำหรับพื้นหลังไล่ระดับสี
    final gradient = LinearGradient(
      colors: [Colors.orange.shade200, Colors.orange.shade400],
      begin: Alignment.centerLeft, // เริ่มไล่สีจากซ้ายกลาง
      end: Alignment.centerRight, // ไปสิ้นสุดที่ขวากลาง
    );

    // สีเติมของฟองข้อความ (ใช้ gradient)
    final paintFill =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          )
          ..style = PaintingStyle.fill;

    // สีขอบของฟองข้อความ
    final paintStroke =
        Paint()
          ..color = Colors.orange.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // กล่องโค้ง
    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      const Radius.circular(30),
    );

    // วาดกล่องพื้นหลังแบบไล่สี
    canvas.drawRRect(rrect, paintFill);
    // วาดขอบกล่อง
    canvas.drawRRect(rrect, paintStroke);

    // สร้าง path หางด้านซ้าย
    final path = Path();
    path.moveTo(0, size.height / 2 - 10);
    path.lineTo(-20, size.height / 1.5);
    path.lineTo(0, size.height / 2 + 15);
    path.close();

    // วาดหางเติมสี
    canvas.drawPath(path, paintFill);
    // วาดขอบหาง
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
