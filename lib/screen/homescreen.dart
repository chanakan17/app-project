import 'package:app/screen/dicscreen.dart';
import 'package:app/screen/menuscreen.dart';
import 'package:app/screen/profilescreen.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: TabBarView(
        controller: _tabController,
        children: const [Menuscreen(), Dicscreen(), Profilescreen()],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 5, thickness: 2, color: Colors.grey),
          Container(
            height: 70,
            child: Material(
              // color: Colors.blue,
              child: TabBar(
                controller: _tabController,
                // labelColor: Colors.white,
                // unselectedLabelColor: Colors.white70,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 6,
                ),
                indicator: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // สีของกรอบ
                    width: 2.0, // ความหนาของกรอบ
                  ),
                  borderRadius: BorderRadius.circular(8), // ขอบโค้ง
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
    );
  }
}
