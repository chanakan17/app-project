import 'package:app/management/dicanimal.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dicaniscreen extends StatefulWidget {
  const Dicaniscreen({super.key});

  @override
  State<Dicaniscreen> createState() => _DicaniscreenState();
}

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

class _DicaniscreenState extends State<Dicaniscreen> {
  // final TextEditingController _controller = TextEditingController();
  // String result = '';
  List<MapEntry<String, List<String>>> searchResults = [];
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speakWord(String word) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 25,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return HomeScreen(initialTabIndex: 1);
                },
              ),
            );
          },
        ),
        title: Text("คำศัพท์สัตว์"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextField(
                //   controller: _controller,
                //   decoration: InputDecoration(
                //     labelText: 'Enter a word',
                //     border: OutlineInputBorder(),
                //   ),
                //   onChanged: (query) {
                //     searchWord(query);
                //   },
                // ),
                // SizedBox(height: 10),
                // Text(result, style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children:
                        (searchResults.isNotEmpty
                                ? searchResults
                                : (dicAnimal.entries.entries.toList()
                                  ..sort((a, b) => a.key.compareTo(b.key))))
                            .map((entry) {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: IconButton(
                                        onPressed: () => _speakWord(entry.key),
                                        icon: Icon(Icons.volume_up, size: 30),
                                      ),
                                      title: Text(entry.key),
                                      subtitle: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...entry.value.map((subtitle) {
                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(subtitle),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    color: Colors.grey,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                ],
                              );
                            })
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void searchWord(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       result = 'กรุณากรอกคำค้นหา';
  //       searchResults.clear();
  //     } else {
  //       searchResults =
  //           dicAnimal.entries.entries
  //               .where(
  //                 (entry) =>
  //                     entry.key.toLowerCase().contains(query.toLowerCase()) ||
  //                     entry.value.any(
  //                       (subtitle) => subtitle.toLowerCase().contains(
  //                         query.toLowerCase(),
  //                       ),
  //                     ),
  //               )
  //               .toList();

  //       searchResults.sort((a, b) => a.key.compareTo(b.key));

  //       if (searchResults.isEmpty) {
  //         result = 'ไม่พบคำแปลที่ตรงกับคำค้นหา';
  //       } else {
  //         result = 'พบผลลัพธ์การค้นหา';
  //       }
  //     }
  //   });
  // }
}
