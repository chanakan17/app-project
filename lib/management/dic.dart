import 'dart:convert';
import 'package:http/http.dart' as http;

class DicService {
  static Future<List<DicEntry>> fetchWords({int categoryId = 1}) async {
    var url = Uri.parse(
      "http://192.168.1.125/dataweb/get_words.php?category_id=1",
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
