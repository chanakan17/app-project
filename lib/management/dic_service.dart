import 'dart:convert';
import 'package:http/http.dart' as http;

class DicService {
  static const String _baseUrl = "http://192.168.1.147/dataweb/get_words.php";

  static Future<List<DicEntry>> fetchWords({int categoryId = 1}) {
    return _fetchWordsByCategory(categoryId);
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
