import 'dart:convert';
import 'package:app/api_config.dart';
import 'package:http/http.dart' as http;

class DicService {
  static const String _baseUrl = "${ApiConfig.baseUrl}/get_words.php";

  static Future<List<DicEntry>> fetchWords({int categoryId = 1}) {
    return _fetchWordsByCategory(categoryId);
  }

  static Future<List<DicEntry>> fetchRandomWords({
    int count = 20,
    int categoryId = 1,
  }) async {
    List<DicEntry> allWords = await _fetchWordsByCategory(categoryId);

    allWords.shuffle();

    if (allWords.length > count) {
      return allWords.sublist(0, count);
    } else {
      return allWords;
    }
  }

  static Future<List<DicEntry>> _fetchWordsByCategory(int categoryId) async {
    final url = Uri.parse("$_baseUrl?category_id=$categoryId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DicEntry.fromJson(e)).toList();
    } else {
      throw Exception("โหลดคำศัพท์ล้มเหลว (หมวดหมู่ $categoryId)");
    }
  }
}

class DicEntry {
  final String word;
  final String meaning;
  final String imageUrl;

  DicEntry({required this.word, required this.meaning, required this.imageUrl});

  factory DicEntry.fromJson(Map<String, dynamic> json) {
    return DicEntry(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
