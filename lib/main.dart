import 'package:app/screen/homescreen.dart';
import 'package:app/screen/login/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';
import 'package:app/management/game_data/game_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  final isGuest = prefs.getBool('isGuest') ?? false;
  if (userId != null) {
    GameData.userId = userId;
    print("Restore UserID: $userId");
  } else {
    GameData.userId = 0;
  }
  runApp(MyApp(userId: userId, isGuest: isGuest));
}

class MyApp extends StatefulWidget {
  final int? userId;
  final bool isGuest;

  const MyApp({super.key, required this.userId, required this.isGuest});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late InternetService _internetService;
  late StreamSubscription<bool> _internetSubscription;
  bool _hasInternet = true;
  bool _initialCheckComplete = false;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _internetService = InternetService();

    // ฟังสถานะอินเทอร์เน็ต
    _internetSubscription = _internetService.internetStatusStream.listen((
      status,
    ) {
      setState(() {
        _hasInternet = status;
        _initialCheckComplete = true;
      });
    });
  }

  @override
  void dispose() {
    _internetSubscription.cancel();
    _internetService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'DicOfEng',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home:
          !_initialCheckComplete
              ? const SplashScreen() // รอเช็กอินเทอร์เน็ตก่อน
              : !_hasInternet
              ? const NoInternetScreen() // แสดงหน้าค้าง
              : (widget.userId != null || widget.isGuest)
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.wifi_off, color: Colors.white, size: 64),
            SizedBox(height: 20),
            Text(
              'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class InternetService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivitySubscription;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get internetStatusStream => _controller.stream;

  InternetService() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _checkInternet,
    );
    _checkInternet(null);
  }

  Future<void> _checkInternet(ConnectivityResult? result) async {
    bool isConnected = await InternetConnectionChecker().hasConnection;
    _controller.sink.add(isConnected);
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _controller.close();
  }
}
