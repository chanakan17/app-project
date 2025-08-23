import 'package:app/management/dicsp.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dicsportscreen extends StatefulWidget {
  const Dicsportscreen({super.key});

  @override
  State<Dicsportscreen> createState() => _DicsportscreenState();
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
          child: Container(color: Colors.white, height: 1.0),
        ),
        backgroundColor: Color(0xFFFFF895),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image/bg.png', fit: BoxFit.cover),
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
