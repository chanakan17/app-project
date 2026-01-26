import 'package:app/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _controller = TextEditingController();
  final translator = GoogleTranslator();

  String originalText = '';
  String translatedText = '';
  bool isTranslating = false;

  // ค่าเริ่มต้น: จากไทย ไป อังกฤษ
  String fromLang = 'en';
  String toLang = 'th';

  @override
  Widget build(BuildContext context) {
    String fromLabel = fromLang == 'th' ? 'ไทย' : 'อังกฤษ';
    String toLabel = toLang == 'th' ? 'ไทย' : 'อังกฤษ';
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 25,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return HomeScreen(initialTabIndex: 1);
                },
              ),
            );
          },
        ),
        title: Text(
          "แปลภาษา $fromLabel → $toLabel",
          style: TextStyle(fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black26, height: 2.0),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            tooltip: 'สลับภาษา',
            onPressed: () {
              setState(() {
                final temp = fromLang;
                fromLang = toLang;
                toLang = temp;
                translatedText = '';
              });

              if (originalText.trim().isNotEmpty) {
                translateText(originalText);
              }
            },
          ),
        ],
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.amber[50],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'พิมพ์คำหรือประโยค ($fromLabel)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      originalText = text;
                      translatedText = '';
                      isTranslating = true;
                    });
                    if (text.trim().isEmpty) {
                      setState(() {
                        translatedText = '';
                        isTranslating = false;
                      });
                      return;
                    }
                    translateText(text);
                  },
                ),
                SizedBox(height: 20),
                if (originalText.trim().isEmpty)
                  Text('กรุณากรอกคำหรือประโยค', style: TextStyle(fontSize: 18))
                else if (isTranslating)
                  CircularProgressIndicator()
                else
                  ListTile(
                    title: Text(
                      originalText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      translatedText,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void translateText(String input) async {
    try {
      var translation = await translator.translate(
        input,
        from: fromLang,
        to: toLang,
      );
      setState(() {
        translatedText = translation.text;
        isTranslating = false;
      });
    } catch (e) {
      setState(() {
        translatedText = 'เกิดข้อผิดพลาดในการแปล';
        isTranslating = false;
      });
    }
  }
}
