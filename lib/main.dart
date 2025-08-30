import 'package:app/screen/homescreen.dart';
import 'package:app/screen/login/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  final isGuest = prefs.getBool('isGuest') ?? false;

  runApp(MyApp(userId: userId, isGuest: isGuest));
}

class MyApp extends StatelessWidget {
  final int? userId;
  final bool isGuest;

  const MyApp({super.key, required this.userId, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DicOfEng',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.deepPurple,
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      // themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,

      // ✅ เลือกหน้าแรกตามว่า login แล้วหรือยัง
      home:
          (userId != null || isGuest)
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
