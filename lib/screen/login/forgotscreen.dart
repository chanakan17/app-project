import 'dart:convert';
import 'package:app/api_config.dart';
import 'package:app/screen/login/forgotrscreen.dart';
import 'package:app/screen/login/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Forgotscreen extends StatefulWidget {
  const Forgotscreen({super.key});

  @override
  State<Forgotscreen> createState() => _ForgotscreenState();
}

class _ForgotscreenState extends State<Forgotscreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  // ลบ _usernameController ออก
  final _dateController = TextEditingController(); // นำกลับมาใช้

  DateTime? _selectedDate; // ตัวแปรเก็บวันที่ที่เลือก

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/reset_forgot.php'),
          body: {
            // ลบ username ออก
            'email': _emailController.text.trim(),
            // ส่ง birthdate ไปตรวจสอบแทน
            'birthdate': _selectedDate!.toIso8601String().substring(0, 10),
          },
        );

        print('Response body: ${response.body}');

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('Success, navigating...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      Forgotrscreen(email: _emailController.text.trim()),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'เกิดข้อผิดพลาด')),
          );
        }
      } catch (e) {
        print('Error during request: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _dateController.dispose(); // คืนทรัพยากรตัวแปร date
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 25,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              ),
            );
          },
        ),
        title: Text("ลืมรหัสผ่าน ?"),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.orangeAccent,
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'กรอกข้อมูลเพื่อยืนยัน',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- ช่องกรอก Email ---
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'อีเมล',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกอีเมล';
                        }
                        if (!value.contains('@')) {
                          return 'รูปแบบอีเมลไม่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // --- ช่องเลือกวันเกิด (นำกลับมาแทน Username) ---
                    TextFormField(
                      controller: _dateController,
                      readOnly: true, // ห้ามพิมพ์เอง ต้องกดเลือกจากปฏิทิน
                      decoration: const InputDecoration(
                        labelText: 'วันเกิด',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            // แสดงผลวันที่ใน format วัน/เดือน/ปี
                            _dateController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'กรุณาเลือกวันเกิด';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LoginScreen();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                              ),
                              onPressed: _submitForm,
                              child: const Text(
                                'ถัดไป',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
