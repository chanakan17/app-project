import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  static const String _baseUrl = "http://10.33.87.68/dataweb/geta_words.php";

  // ดึงทั้งหมด
  static Future<List<DicEntry>> fetchAllWords() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DicEntry.fromJson(e)).toList();
    } else {
      throw Exception("โหลดคำศัพท์ทั้งหมดล้มเหลว");
    }
  }

  // ดึงตามหมวดหมู่
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
  final String category; // เพิ่มหมวด

  DicEntry({
    required this.word,
    required this.meaning,
    required this.imageUrl,
    required this.category,
  });

  factory DicEntry.fromJson(Map<String, dynamic> json) {
    return DicEntry(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
