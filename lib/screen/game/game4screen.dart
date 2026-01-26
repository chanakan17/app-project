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

  // Timer สำหรับจับเงียบเสียง (เพื่อให้ไมค์ตัดอัตโนมัติ) ยังคงไว้
  Timer? _silenceTimer;

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
    GameData.reset();
    GameData.gameName = 'เกมพูดคำศัพท์';
    GameData.title = widget.title;
  }

  // ลบฟังก์ชัน _endGame ที่คำนวณเวลาออก เหลือแค่ logic จบเกมพื้นฐาน
  void _endGame() {
    // ไม่มีการคำนวณ PlayTime แล้ว
  }

  // ลบฟังก์ชัน _formatTime ออก

  void _loadNextQuestion() {
    if (availableKeys.isEmpty) {
      _showFinishDialog();
      return;
    }

    var rand = Random();
    int randomIndex = rand.nextInt(availableKeys.length);
    currentKey = availableKeys[randomIndex];
    availableKeys.removeAt(randomIndex);

    var values = typeDic[currentKey]!;
    correctValue = values[0];
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
          localeId: 'en_US',
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords.trim();
            });

            // จับเวลาหยุดฟังอัตโนมัติ (อันนี้เก็บไว้เพื่อให้ไมค์ปิดเองเมื่อพูดจบ)
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
    String userWord = _spokenText.trim().toLowerCase();
    String correctWord = currentKey.trim().toLowerCase();

    bool isCorrect = false;

    if (userWord == correctWord || userWord.contains(correctWord)) {
      isCorrect = true;
    } else {
      int threshold = correctWord.length > 4 ? 2 : 1;
      int distance = _calculateLevenshtein(userWord, correctWord);

      if (distance <= threshold) {
        isCorrect = true;
      }
    }

    setState(() {
      _feedback =
          isCorrect
              ? "✅ ถูกต้อง! (ได้ยินว่า: $_spokenText)"
              : "❌ ผิด! คำตอบคือ: $currentKey";
    });

    if (isCorrect) {
      // score++;
      GameData.score = score;
      SoundManager.playChecktrueSound();
    } else {
      // scoredis--;
      SoundManager.playCheckfalseSound();
    }

    if (scoredis < 1) {
      _showFinishDialog();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResultModal(isCorrect, [
        TextSpan(
          text: currentKey,
          style: TextStyle(color: isCorrect ? Color(0xFFFFA000) : Colors.red),
        ),
      ]);
    });
  }

  void _showResultModal(bool isCorrect, List<TextSpan> textSpans) {
    final Color mainColor =
        isCorrect
            ? const Color(0xFFFFCA28)
            : const Color.fromARGB(255, 255, 81, 81);
    final Color shadowColor =
        isCorrect
            ? const Color(0xFFFFA000)
            : const Color.fromARGB(255, 221, 15, 0);
    final IconData icon = isCorrect ? Icons.check : Icons.close;
    final String titleText = isCorrect ? "ถูกต้องแล้ว" : "ผิดจร้าาา";
    final Color titleColor = isCorrect ? Color(0xFFFFA000) : Colors.red;

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
          color: Colors.white,
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
                      Icon(icon, color: titleColor, size: 40),
                      const SizedBox(width: 8),
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "$currentKey --> $correctValue",
                    style: TextStyle(fontSize: 20, color: titleColor),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        // ลบ _stopwatch.start() ออก
                        _loadNextQuestion();
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 320,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border(
                                bottom: BorderSide(
                                  color: shadowColor,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: const Text(
                              'ไปข้อต่อไป',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("จบแล้ว!"),
          content: Text("คุณทำคะแนนได้ทั้งหมด $score คะแนน"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // ลบการเรียก _endGame() ที่เกี่ยวกับเวลาออก
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(initialTabIndex: 1),
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

  @override
  void dispose() {
    _silenceTimer?.cancel();
    // ลบ _stopwatch.stop() และ _timer?.cancel() ออก
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ฝึกพูดคำศัพท์",
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
              // ลบ _stopwatch.stop() ออก
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "คุณต้องการออกหรือไม่?",
                      style: TextStyle(fontSize: 21),
                    ),
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
                                return HomeScreen(initialTabIndex: 1);
                              },
                            ),
                          );
                        },
                        child: Text(
                          "ยืนยันการออก",
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
                          // ลบ _stopwatch.start() ออก
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Text(
                        "ฝึกพูดคำศัพท์ต่อไปนี้",
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
                    print("Button pressed");
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
                SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _loadNextQuestion();
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
                        'เปลี่ยนคำถัดไป',
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
    );
  }

  int _calculateLevenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [Colors.orange.shade200, Colors.orange.shade400],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final paintFill =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          )
          ..style = PaintingStyle.fill;

    final paintStroke =
        Paint()
          ..color = Colors.orange.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      const Radius.circular(30),
    );

    canvas.drawRRect(rrect, paintFill);
    canvas.drawRRect(rrect, paintStroke);

    final path = Path();
    path.moveTo(0, size.height / 2 - 10);
    path.lineTo(-20, size.height / 1.5);
    path.lineTo(0, size.height / 2 + 15);
    path.close();

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
