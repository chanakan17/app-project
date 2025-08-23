import 'package:app/management/dicanimal.dart';
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dicaniscreen extends StatefulWidget {
  const Dicaniscreen({super.key});

  @override
  State<Dicaniscreen> createState() => _DicaniscreenState();
}

class _DicaniscreenState extends State<Dicaniscreen> {
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
    final allEntries = dicAnimal.entries.entries.toList();
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
                      ) || // ✅ ขึ้นต้นเท่านั้น
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
        title: Text("คำศัพท์สัตว์"),
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
                // 🔎 ช่องค้นหา
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "ค้นหาคำศัพท์สัตว์...",
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
                  child:
                      searchResults.isEmpty && _searchController.text.isNotEmpty
                          ? Center(
                            child: Text(
                              "ไม่พบคำศัพท์",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                          : ListView(
                            children:
                                (searchResults.isNotEmpty ||
                                            _searchController.text.isNotEmpty
                                        ? searchResults
                                        : (dicAnimal.entries.entries.toList()
                                          ..sort(
                                            (a, b) => a.key.compareTo(b.key),
                                          )))
                                    .map((entry) {
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListTile(
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
                                                            child: Text(
                                                              subtitle,
                                                            ),
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
