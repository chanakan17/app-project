import 'dart:math';
import 'package:app/management/sound/sound.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Game3screen extends StatefulWidget {
  final Map<String, List<String>> dictionary;

  const Game3screen({super.key, required this.dictionary});

  @override
  State<Game3screen> createState() => _Game3screenState();
}

late Map<String, List<String>> typeDic;

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // ถ้า path ของคุณไม่เปลี่ยนแปลง ให้คืนค่า false
    return false;
  }
}

class _Game3screenState extends State<Game3screen> {
  List<String> randomKeys = [];
  List<String> randomValues = [];
  List<String> maskedCharacters = [];
  List<TextEditingController> controllers = [];
  int score = 0;
  int scoredis = 5;
  late List<String> availableKeys;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    typeDic = widget.dictionary;
    availableKeys = typeDic.keys.toList();
    _getRandomEntries();
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

  void _getRandomEntries() {
    if (availableKeys.isEmpty) {
      _showFinishDialog();
      return;
    }

    randomKeys.clear();
    randomValues.clear();

    String randomKey = getRandomKey();
    randomKeys.add(randomKey);
    randomValues.add(getRandomValue(typeDic[randomKey]!));

    availableKeys.remove(randomKey);

    _maskWord(randomKey);
    setState(() {});
  }

  String getRandomKey() {
    var random = Random();
    return availableKeys[random.nextInt(availableKeys.length)];
  }

  String getRandomValue(List<String> values) {
    var random = Random();
    return values[random.nextInt(values.length)];
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
      } else {
        scoredis--;
      }

      if (scoredis < 1) {
        _showFinishDialog();
        return;
      }

      if (userInput.toLowerCase() == randomKeys[0].toLowerCase()) {
        SoundManager.playChecktrueSound();
        showModalBottomSheet(
          context: context,
          isDismissible: false, // ไม่ให้ปิดเมื่อแตะนอกพื้นที่
          enableDrag: false, // ไม่ให้ลาก bottom sheet ออกได้
          isScrollControlled: true, // ควบคุมการ scroll ของเนื้อหา
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // <-- ทำให้ไม่โค้งเลย
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
                            color: Colors.green, // สีเขียว
                            size: 40, // ขนาด
                          ),
                          Text(
                            "ถูกต้องแล้ว",
                            style: TextStyle(fontSize: 25, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${randomValues[0]} --> ${randomKeys[0]}",
                        style: TextStyle(fontSize: 20, color: Colors.green),
                      ),
                    ),
                    Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // ปิด dialog
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
                                  color: Color(0xFF4CD200), // สีเขียวหลัก
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF3ABA00),
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
      } else {
        SoundManager.playCheckfalseSound();
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // <-- ทำให้ไม่โค้งเลย
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
                            "ผิดจร้าาา",
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
                        "${randomValues[0]} --> ${randomKeys[0]}",
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("เกมเติมคำ"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // ความสูงของเส้น
          child: Container(
            color: Colors.grey, // สีของเส้น
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
            child: Center(
              child: Column(
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                        child: Text(
                          "เติมคำในช่องว่าให้ถูกต้อง",
                          style: TextStyle(fontSize: 23),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          5,
                                          15,
                                          0,
                                          0,
                                        ),
                                        child: Text(
                                          '${randomValues[0]}',
                                          style: TextStyle(fontSize: 25),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
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
                            color: Color(0xFF4CD200), // สีเขียวหลัก
                            borderRadius: BorderRadius.circular(25),
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF3ABA00),
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
                              fontSize: 16,
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
