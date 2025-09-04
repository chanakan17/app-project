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
        backgroundColor: Color(0xFFFFD96A),
        body: TabBarView(
          controller: _tabController,
          children: const [Menuscreen(), Dicscreen(), Profilescreen()],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Divider(height: 5, thickness: 2, color: Colors.white),
            Container(
              color: Color(0xFFFFD96A),
              height: 70,
              child: Material(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 6,
                  ),
                  indicator: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white24,
                  ),
                  tabs: [
                    Tab(icon: Image.asset('assets/icons/game96.png')),
                    Tab(icon: Image.asset('assets/icons/bookdic100.png')),
                    Tab(icon: Image.asset('assets/icons/profile80.png')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
