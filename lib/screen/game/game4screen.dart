import 'dart:async';
import 'dart:math';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class Game4screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;

  const Game4screen({super.key, required this.dictionary});

  @override
  State<Game4screen> createState() => _Game4screenState();
}

class _Game4screenState extends State<Game4screen> {
  late Map<String, List<String>> typeDic;
  late List<String> availableKeys;
  late String currentKey;
  late String correctValue;

  int score = 0;
  String _spokenText = "";
  String _feedback = "";
  bool _isListening = false;

  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    typeDic = widget.dictionary;
    availableKeys = typeDic.keys.toList();
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
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
          localeId: 'en-TH',
          onResult: (result) {
            if (result.recognizedWords.trim().isNotEmpty) {
              setState(() {
                _spokenText = result.recognizedWords.trim();
              });

              _silenceTimer?.cancel();
              _silenceTimer = Timer(Duration(milliseconds: 1200), () {
                _speech.stop();
                setState(() => _isListening = false);
                _checkAnswer();
              });
            }
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          listenFor: Duration(minutes: 5),
          pauseFor: Duration(seconds: 5),
        );
      }
    } else {
      _speech.stop();
      _silenceTimer?.cancel();
      setState(() => _isListening = false);
    }
  }

  void _checkAnswer() {
    List<TextSpan> textSpans = [];
    bool isCorrect = true;

    for (int i = 0; i < currentKey.length; i++) {
      String userChar = _spokenText.length > i ? _spokenText[i] : '';
      String correctChar = currentKey[i];

      if (userChar.toLowerCase() == correctChar.toLowerCase()) {
        textSpans.add(
          TextSpan(text: correctChar, style: TextStyle(color: Colors.green)),
        );
      } else {
        textSpans.add(
          TextSpan(text: correctChar, style: TextStyle(color: Colors.red)),
        );
        isCorrect = false;
      }
    }

    setState(() {
      _feedback =
          isCorrect ? "✅ ถูกต้อง! ได้คะแนน +1" : "❌ ผิด! คำตอบคือ: $currentKey";
    });

    if (isCorrect) {
      SoundManager.playChecktrueSound();
    } else {
      SoundManager.playCheckfalseSound();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  isCorrect ? "✅ ถูกต้อง!" : "❌ ผิดจร้าาา",
                  style: TextStyle(fontSize: 25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(children: textSpans),
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(" = $correctValue", style: TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isCorrect)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("อีกครั้ง"),
                      ),
                    if (!isCorrect) SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (isCorrect) score++;
                        _loadNextQuestion();
                      },
                      child: Text("ไปต่อ"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เกมพูดคำศัพท์ภาษาอังกฤษ"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // ความสูงของเส้น
          child: Container(
            color: Colors.black, // สีของเส้น
            height: 1.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 40,
            onPressed: () {
              SoundManager.playClickSound();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("คุณต้องการออกจากเกมหรือไม่?"),
                    content: Text("หากคุณออกจากเกม ข้อมูลจะไม่ได้รับการบันทึก"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          SoundManager.playClickSound();
                          Navigator.of(context).pop();
                        },
                        child: Text("อยู่ต่อ"),
                      ),
                      TextButton(
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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('คะแนน: $score', style: TextStyle(fontSize: 22)),
              SizedBox(height: 30),
              Text(
                "ฟังคำศัพท์แล้วพูดออกเสียงตาม (ภาษาอังกฤษ)",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: _speakWord,
                      icon: Icon(Icons.volume_up, size: 30),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currentKey,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _listen,
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
      ),
    );
  }
}
