import 'package:http/http.dart' as http;
import 'dart:convert';

class GameData {
  static int userId = 0;
  static String gameName = '';
  static String title = '';
  static int score = 0;
  static int playTimeMs = 0; // เวลาเล่นเป็น millisecond
  static String playTimeStr = ''; // เวลาเล่นแบบ mm:ss:ms

  static String showName1 = '';
  static String showName2 = '';
  static String showName3 = '';
  static String showTitle1 = '';
  static String showTitle2 = '';
  static String showTitle3 = '';
  static int showScore1 = 0;
  static int showScore2 = 0;
  static int showScore3 = 0;

  static void reset() {
    gameName = '';
    title = '';
    score = 0;
    playTimeMs = 0;
    playTimeStr = '';
  }

  static void updateTopScore() {
    if (score > showScore1) {
      showScore3 = showScore2;
      showTitle3 = showTitle2;
      showName3 = showName2;

      showScore2 = showScore1;
      showTitle2 = showTitle1;
      showName2 = showName1;

      showScore1 = score;
      showTitle1 = title;
      showName1 = gameName;
    } else if (score > showScore2 && score <= showScore1) {
      showScore3 = showScore2;
      showTitle3 = showTitle2;
      showName3 = showName2;

      showScore2 = score;
      showTitle2 = title;
      showName2 = gameName;
    } else if (score > showScore3 && score <= showScore2) {
      showScore3 = score;
      showTitle3 = title;
      showName3 = gameName;
    }
  }

  // บันทึกคะแนนลงฐานข้อมูล
  static Future<void> saveScoreToDB() async {
    final url = Uri.parse('http://172.30.160.1/dataweb/save_score.php');
    final response = await http.post(
      url,
      body: {
        'user_id': userId.toString(),
        'game_title': title,
        'score': score.toString(),
        'game_name': gameName,
        'play_time_str': playTimeStr,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('บันทึกคะแนนสำเร็จ');
      } else {
        print('บันทึกคะแนนไม่สำเร็จ');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  }

  // โหลด Top 3 คะแนนจากฐานข้อมูล
  static Future<void> loadTopScores() async {
    final url = Uri.parse(
      'http://172.30.160.1/dataweb/get_top_scores.php?user_id=$userId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        showName1 = data.length > 0 ? data[0]['game_name'] : '';
        showTitle1 = data.length > 0 ? data[0]['game_title'] : '';
        showScore1 =
            data.length > 0 ? int.parse(data[0]['score'].toString()) : 0;

        showName2 = data.length > 1 ? data[1]['game_name'] : '';
        showTitle2 = data.length > 1 ? data[1]['game_title'] : '';
        showScore2 =
            data.length > 1 ? int.parse(data[1]['score'].toString()) : 0;

        showName3 = data.length > 2 ? data[2]['game_name'] : '';
        showTitle3 = data.length > 2 ? data[2]['game_title'] : '';
        showScore3 =
            data.length > 2 ? int.parse(data[2]['score'].toString()) : 0;
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  }

  static Map<String, List<Map<String, dynamic>>> topScoresByGame = {};

  static Future<void> loadTopScores1() async {
    // ตรวจสอบ URL ให้ถูกต้อง (แก้ IP ให้ตรงกับเครื่องคุณ)
    final url = Uri.parse('http://172.30.160.1/dataweb/get_topa_scores.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // decode แบบ utf8 เพื่อรองรับภาษาไทย
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data is Map<String, dynamic>) {
          topScoresByGame.clear();

          data.forEach((gameName, categoryMap) {
            if (categoryMap is Map<String, dynamic>) {
              topScoresByGame.putIfAbsent(gameName, () => []);

              categoryMap.forEach((category, topList) {
                if (topList is List) {
                  for (var item in topList) {
                    topScoresByGame[gameName]!.add({
                      "category": category,
                      "username": item['username'],
                      "score": item['score'],
                      "time": item['time'],
                      // ✅✅✅ เพิ่มบรรทัดนี้ครับ เพื่อรับค่ารูปภาพ ✅✅✅
                      "image_id": item['image_id'],
                    });
                  }
                }
              });
            }
          });
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading top scores: $e");
    }
  }
}
