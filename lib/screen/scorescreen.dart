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

  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId == null) return "";

    try {
      final url = Uri.parse(
        'http://10.161.225.68/dataweb/get_user.php?id=$userId',
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

  // 🔹 แสดง pop-up ของแต่ละเกม
  void showGamePopup(String title) {
    final scores = topScores[title] ?? [];
    final grouped = _groupByCategory(scores);

    if (scores.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(title),
              content: const Text("ยังไม่มีข้อมูลคะแนน"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ปิด"),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: DefaultTabController(
            length: grouped.keys.length,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TabBar(
                        isScrollable: false, // ให้ทุก tab ขยายเท่ากัน
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black87,
                        labelPadding:
                            EdgeInsets.zero, // เอาช่องว่างรอบข้อความออก
                        tabs:
                            grouped.keys.map((c) {
                              return Tab(
                                child: SizedBox.expand(
                                  child: Center(
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children:
                        grouped.entries.map((entry) {
                          final items = entry.value;
                          return ListView(
                            padding: const EdgeInsets.all(12),
                            children:
                                items.map((game) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: game["color"],
                                        child: Text(
                                          game["rank"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        "👤 ${game["username"]}",
                                        style: TextStyle(
                                          color: game["usernameColor"],
                                        ),
                                      ),
                                      subtitle: Text("⏱ ${game["time"]}"),
                                      trailing: Text(
                                        game["score"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        }).toList(),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.black26),
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: "ปิด",
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                //   child: ElevatedButton.icon(
                //     onPressed: () => Navigator.pop(context),
                //     icon: const Icon(Icons.close),
                //     label: const Text(
                //       "ปิด",
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.orange,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 24,
                //         vertical: 12,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Score Board",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: Colors.orangeAccent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "🏆 เลือกเกมที่ต้องการดูคะแนน",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: gameTitles.length,
                itemBuilder: (context, index) {
                  final title = gameTitles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => showGamePopup(title),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videogame_asset),
                          const SizedBox(width: 8),
                          Text(title, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
