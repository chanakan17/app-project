import 'package:app/management/dic.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dicallscreen extends StatefulWidget {
  const Dicallscreen({super.key});

  @override
  State<Dicallscreen> createState() => _DicallscreenState();
}

class _DicallscreenState extends State<Dicallscreen> {
  List<MapEntry<String, List<String>>> searchResults = [];
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();

  Future<void> _speakWord(String word) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(word);
  }

  void _filterSearchResults(String query) {
    final allEntries = Dic.entries.entries.toList();
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
                      entry.key.toLowerCase().startsWith(
                        query.toLowerCase(),
                      ) || // ค้นหาคำศัพท์ขึ้นต้น
                      entry.value.any(
                        (v) => v.toLowerCase().startsWith(query.toLowerCase()),
                      ),
                ) // ค้นหาคำแปลขึ้นต้น
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
        title: Text("คำศัพท์ยานพาหนะ"),
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
                // 🔎 Search Box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "ค้นหาคำศัพท์...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: _filterSearchResults,
                ),
                SizedBox(height: 20),

                // 📖 แสดงรายการ
                Expanded(
                  child: ListView(
                    children:
                        (searchResults.isNotEmpty ||
                                    _searchController.text.isNotEmpty
                                ? searchResults
                                : (Dic.entries.entries.toList()
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
}
