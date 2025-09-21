import 'dart:convert';
import 'package:app/management/dic.dart'; // ✅ ต้องมี DicEntry class
import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class Dicsportscreen extends StatefulWidget {
  const Dicsportscreen({super.key});

  @override
  State<Dicsportscreen> createState() => _DicsportscreenState();
}

class _DicsportscreenState extends State<Dicsportscreen> {
  List<DicEntry> _allWords = [];
  List<DicEntry> _searchResults = [];
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      var url = Uri.parse(
        "http://192.168.1.109/dataweb/get_words.php?category_id=4", // 🎯 category_id = 4 สำหรับกีฬา
      );
      var response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        List<DicEntry> words = data.map((e) => DicEntry.fromJson(e)).toList();
        setState(() {
          _allWords = words;
          _searchResults = [];
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load words");
      }
    } catch (e) {
      setState(() {
        _error = 'ไม่สามารถโหลดข้อมูลได้: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _speakWord(String word) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(word);
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results =
        _allWords.where((entry) {
          final wordLower = entry.word.toLowerCase();
          final meaningLower = entry.meaning.toLowerCase();
          final queryLower = query.toLowerCase();
          return wordLower.contains(queryLower) ||
              meaningLower.contains(queryLower);
        }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList =
        _searchResults.isNotEmpty || _searchController.text.isNotEmpty
            ? _searchResults
            : _allWords;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 25,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(initialTabIndex: 1),
              ),
            );
          },
        ),
        title: Text("คำศัพท์กีฬา"),
        backgroundColor: Color(0xFFFFD54F),
      ),
      backgroundColor: Color(0xFFFFE082),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset('assets/image/bg.png', fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "ค้นหาคำศัพท์กีฬา...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: _filterSearchResults,
                ),
                SizedBox(height: 20),

                // 📖 Display Word List
                Expanded(
                  child:
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _error.isNotEmpty
                          ? Center(child: Text(_error))
                          : displayList.isEmpty
                          ? Center(child: Text('ไม่พบคำศัพท์'))
                          : ListView.separated(
                            itemCount: displayList.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  thickness: 1.5,
                                  color: Colors.grey,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            itemBuilder: (context, index) {
                              final entry = displayList[index];
                              return ListTile(
                                leading: IconButton(
                                  onPressed: () => _speakWord(entry.word),
                                  icon: Icon(Icons.volume_up, size: 30),
                                ),
                                title: Text(entry.word),
                                subtitle: Text(entry.meaning),
                                trailing:
                                    entry.imageUrl.isNotEmpty
                                        ? Image.network(
                                          entry.imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              );
                            },
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
