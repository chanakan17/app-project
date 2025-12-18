import 'package:app/screen/scorescreen.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/menuscreen.dart';
import 'package:app/screen/dicscreen.dart';
import 'package:app/screen/profilescreen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.initialTabIndex;

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ป้องกัน Back Button
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.amber[50],
        // backgroundColor: Color(0xFFFFD96A),
        body: TabBarView(
          controller: _tabController,
          children: const [
            Menuscreen(),
            Dicscreen(),
            // Scorescreen(),
            Profilescreen(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
              child: Container(
                // color: Colors.white,
                // color: Color(0xFFFFD96A),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white, // สีพื้นหลังของแท็บ
                  borderRadius: BorderRadius.circular(20), // ความมน
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.2,
                      ), // สีเงา (ใช้สีดำจางๆ จะเห็นชัดกว่าสีเทาบนพื้นสีสด)
                      spreadRadius: 2,
                      blurRadius: 10, // ความฟุ้ง
                      offset: const Offset(0, 5), // เงาตกกระทบลงด้านล่าง
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 6,
                    ),
                    // indicator: BoxDecoration(
                    //   // border: Border.all(color: Colors.grey, width: 2.0),
                    //   // borderRadius: BorderRadius.circular(8),
                    //   // color: Colors.white24,
                    // ),
                    tabs: [
                      // Tab(icon: Image.asset('assets/icons/game96.png')),
                      // Tab(icon: Image.asset('assets/icons/bookdic100.png')),
                      // // Tab(icon: Icon(Icons.score)),
                      // Tab(icon: Image.asset('assets/icons/profile80.png')),
                      Tab(
                        icon: Image.asset(
                          'assets/image/home1.png',
                          color:
                              _tabController.index == 0
                                  ? const Color(0xFFFFA500)
                                  : Colors.grey,
                        ),
                      ),
                      Tab(
                        icon: Image.asset(
                          'assets/image/home2.png',
                          color:
                              _tabController.index == 1
                                  ? const Color(0xFFFFA500)
                                  : Colors.grey,
                        ),
                      ),
                      Tab(
                        icon: Image.asset(
                          'assets/image/home3.png',
                          color:
                              _tabController.index == 2
                                  ? const Color(0xFFFFA500)
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
