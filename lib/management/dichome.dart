import 'dart:convert';
import 'package:http/http.dart' as http;

/// คลาสเก็บข้อมูลคำศัพท์แต่ละคำ
class DicEntry {
  final String word;
  final String meaning;
  final String imageUrl;

  DicEntry({required this.word, required this.meaning, required this.imageUrl});

  factory DicEntry.fromJson(Map<String, dynamic> json) {
    return DicEntry(
      word: json['word'],
      meaning: json['meaning'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}

/// บริการดึงข้อมูลคำศัพท์จาก API
class DicService {
  static Future<List<DicEntry>> fetchWords({required int categoryId}) async {
    final url = Uri.parse(
      "http://172.30.160.1/dataweb/get_words.php?category_id=$categoryId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DicEntry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load words for category $categoryId");
    }
  }
}

/// คลาสสำหรับหมวดคำศัพท์ "ภายในบ้าน"
class DicHome {
  List<DicEntry> _entries = [];

  /// โหลดข้อมูลจากฐานข้อมูล (category_id = 3)
  Future<void> loadEntries() async {
    try {
      _entries = await DicService.fetchWords(categoryId: 3);
    } catch (e) {
      print("❌ Error loading home entries: $e");
    }
  }

  /// คืนรายการคำศัพท์ทั้งหมด
  List<DicEntry> get entries => _entries;
}
