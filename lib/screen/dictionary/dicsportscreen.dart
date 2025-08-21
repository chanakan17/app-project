import 'package:app/management/dicsp.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dicsportscreen extends StatefulWidget {
  const Dicsportscreen({super.key});

  @override
  State<Dicsportscreen> createState() => _DicsportscreenState();
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
    return false;
  }
}

class _DicsportscreenState extends State<Dicsportscreen> {
  List<MapEntry<String, List<String>>> searchResults = [];
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speakWord(String word) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(word);
  }

  void _filterSearchResults(String query) {
    final allEntries = dicSport.entries.entries.toList();
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
    } else {
      setState(() {
        searchResults =
            allEntries
                .where(
                  (entry) =>
                      entry.key.toLowerCase().startsWith(query.toLowerCase()) ||
                      entry.value.any(
                        (v) => v.toLowerCase().startsWith(query.toLowerCase()),
                      ),
                )
                .toList();
      });
    }
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
        title: Text("คำศัพท์กีฬา"),
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
                SizedBox(height: 20),
                TextField(
                  onChanged: _filterSearchResults,
                  decoration: InputDecoration(
                    labelText: "ค้นหาคำศัพท์",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child:
                      (searchResults.isEmpty &&
                              dicSport.entries.entries.isNotEmpty)
                          ? ListView(
                            children:
                                (dicSport.entries.entries.toList()
                                      ..sort((a, b) => a.key.compareTo(b.key)))
                                    .map((entry) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: IconButton(
                                              onPressed:
                                                  () => _speakWord(entry.key),
                                              icon: Icon(
                                                Icons.volume_up,
                                                size: 30,
                                              ),
                                            ),
                                            title: Text(entry.key),
                                            subtitle: Wrap(
                                              children:
                                                  entry.value
                                                      .map(
                                                        (subtitle) => Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: Text(subtitle),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1.5,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      );
                                    })
                                    .toList(),
                          )
                          : (searchResults.isNotEmpty
                              ? ListView(
                                children:
                                    searchResults.map((entry) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: IconButton(
                                              onPressed:
                                                  () => _speakWord(entry.key),
                                              icon: Icon(
                                                Icons.volume_up,
                                                size: 30,
                                              ),
                                            ),
                                            title: Text(entry.key),
                                            subtitle: Wrap(
                                              children:
                                                  entry.value
                                                      .map(
                                                        (subtitle) => Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: Text(subtitle),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1.5,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              )
                              : Center(
                                child: Text(
                                  "ไม่พบคำศัพท์",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
