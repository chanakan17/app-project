import 'dart:convert';
import 'package:app/management/game_data/game_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Scorescreen extends StatefulWidget {
  const Scorescreen({super.key});

  @override
  State<Scorescreen> createState() => _ScorescreenState();
}

class _ScorescreenState extends State<Scorescreen> {
  Map<String, List<Map<String, dynamic>>> topScores = {};
  String currentUsername = "";
  final List<String> gameTitles = [
    "เกมทายคำศัพท์",
    "เกมจับคู่คำศัพท์",
    "เกมเติมคำ",
    "เกมพูดคำศัพท์",
    "เกมทายรูปภาพ",
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUsername().then((value) {
      setState(() {
        currentUsername = value;
      });
      loadScores();
    });
  }

  // ฟังก์ชันดึงชื่อผู้ใช้งานปัจจุบันจาก SharedPreferences และ API
  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId == null) {
      return "";
    }

    try {
      final url = Uri.parse(
        'http://192.168.1.125/dataweb/get_user.php?id=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['username'] ?? "";
      }
    } catch (e) {
      print('Error fetching username: $e');
    }

    return "";
  }

  Future<void> loadScores() async {
    await GameData.loadTopScores();
    await GameData.loadTopScores1();

    setState(() {
      topScores = {
        "เกมทายคำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมทายคำศัพท์"] ?? [],
        ),
        "เกมจับคู่คำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมจับคู่คำศัพท์"] ?? [],
        ),
        "เกมเติมคำ": _getTop3PerCategory(
          GameData.topScoresByGame["เกมเติมคำ"] ?? [],
        ),
        "เกมพูดคำศัพท์": _getTop3PerCategory(
          GameData.topScoresByGame["เกมพูดคำศัพท์"] ?? [],
        ),
        "เกมทายรูปภาพ": _getTop3PerCategory(
          GameData.topScoresByGame["เกมทายรูปภาพ"] ?? [],
        ),
      };
    });
  }

  /// ✅ เก็บคะแนนสูงสุดของแต่ละผู้เล่นในแต่ละหมวดย่อย (category)
  List<Map<String, dynamic>> _getTop3PerCategory(List<dynamic> scores) {
    Map<String, List<dynamic>> grouped = {};
    for (var score in scores) {
      String category = score["category"] ?? "ไม่ระบุหมวด";
      grouped.putIfAbsent(category, () => []).add(score);
    }

    List<Map<String, dynamic>> result = [];

    grouped.forEach((category, list) {
      Map<String, Map<String, dynamic>> bestScores = {};

      for (var s in list) {
        String user = s["username"] ?? "ไม่ระบุชื่อ";
        if (!bestScores.containsKey(user) ||
            (s["score"] ?? 0) > (bestScores[user]!["score"] ?? 0)) {
          bestScores[user] = s;
        }
      }

      List<Map<String, dynamic>> filtered =
          bestScores.values.toList()
            ..sort((a, b) => (b["score"] ?? 0).compareTo(a["score"] ?? 0));

      for (int i = 0; i < filtered.length && i < 3; i++) {
        String user = filtered[i]["username"] ?? "";

        // ✅ เปลี่ยนสีถ้าเป็นของผู้ใช้งาน
        Color rankColor =
            i == 0
                ? Colors.amber
                : i == 1
                ? Colors.grey
                : Colors.brown;

        result.add({
          "rank": (i + 1).toString(),
          "color": rankColor,
          "username": user,
          "usernameColor": user == currentUsername ? Colors.blue : Colors.black,
          "category": category,
          "score": "${filtered[i]["score"] ?? 0} คะแนน",
          "time": filtered[i]["time"] ?? "",
        });
      }
    });

    return result;
  }

  /// ✅ group ข้อมูลในแต่ละแท็บตามหมวดหมู่ย่อย
  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var game in data) {
      final category = game["category"] ?? "ไม่ระบุหมวด";
      grouped.putIfAbsent(category, () => []).add(game);
    }
    return grouped;
  }

  // เพิ่มฟังก์ชันแมปชื่อหมวดเป็นไอคอน
  String getImagePathForCategory(String category) {
    switch (category) {
      case "Animals":
        return "assets/image/animal.png";
      case "House":
        return "assets/image/home.png";
      case "Sports":
        return "assets/image/sport.png";
      case "Vehicles":
        return "assets/image/vehicle.png";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: gameTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Score Board",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Colors.orangeAccent,
        body: Column(
          children: [
            Container(
              color: Colors.orange,
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                tabs: gameTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children:
                    gameTitles.map((title) {
                      final scores = topScores[title] ?? [];
                      final grouped = _groupByCategory(scores);

                      if (scores.isEmpty) {
                        return const Center(child: Text("ยังไม่มีข้อมูลคะแนน"));
                      }

                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children:
                            grouped.entries.map((entry) {
                              final category = entry.key;
                              final items = entry.value;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            getImagePathForCategory(category),
                                            width: 20,
                                            height: 20,
                                          ),

                                          const SizedBox(width: 6),
                                          Text(
                                            "หมวด: $category",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(),
                                      ...items.map((game) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: game["color"],
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  game["rank"],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "👤 ${game["username"]}",
                                                      style: TextStyle(
                                                        color:
                                                            game["usernameColor"] ??
                                                            Colors.black,
                                                      ),
                                                    ),

                                                    Text("⏱ ${game["time"]}"),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                game["score"],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
