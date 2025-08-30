import 'dart:convert';
import 'package:http/http.dart' as http;

/// คลาสข้อมูลคำศัพท์ 1 รายการ
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
    var url = Uri.parse(
      "http://192.168.1.112/dataweb/get_words.php?category_id=$categoryId",
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => DicEntry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load words");
    }
  }
}

/// หมวดหมู่: กีฬา (Sport) - ดึงจาก category_id = 4
class DicSport {
  List<DicEntry> _entries = [];

  /// โหลดข้อมูลจาก API
  Future<void> loadEntries() async {
    try {
      _entries = await DicService.fetchWords(categoryId: 4);
    } catch (e) {
      print("❌ Error loading sport entries: $e");
    }
  }

  /// คืนค่ารายการคำศัพท์
  List<DicEntry> get entries => _entries;
}
