import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TabController, TabBarView;
import 'package:cupertino_native/cupertino_native.dart';

class TabBarDemoPage extends StatefulWidget {
  const TabBarDemoPage({super.key});

  @override
  State<TabBarDemoPage> createState() => _TabBarDemoPageState();
}

class _TabBarDemoPageState extends State<TabBarDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
    _controller.addListener(() {
      final i = _controller.index;
      if (i != _index) setState(() => _index = i);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native Tab Bar'),
      ),
      child: Stack(
        children: [
          // Content below
          Positioned.fill(
            child: TabBarView(
              controller: _controller,
              children: const [
                _ImageTabPage(asset: 'assets/home.jpg', label: 'Home'),
                _ImageTabPage(asset: 'assets/profile.jpg', label: 'Profile'),
                _ImageTabPage(asset: 'assets/settings.jpg', label: 'Settings'),
                _ImageTabPage(asset: 'assets/search.jpg', label: 'Search'),
              ],
            ),
          ),
          // Native tab bar overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: CNTabBar(
              items: const [
                CNTabBarItem(
                  label: 'Home',
                  icon: CNSymbol('house.fill'),
                  badge: '3',
                ),
                CNTabBarItem(
                  label: 'Profile',
                  icon: CNSymbol('person.crop.circle'),
                  badge: null,
                ),
                CNTabBarItem(
                  label: 'Settings',
                  icon: CNSymbol('gearshape.fill'),
                  badge: '',
                ),
                CNTabBarItem(icon: CNSymbol('magnifyingglass')),
              ],
              currentIndex: _index,
              split: true,
              rightCount: 1,
              shrinkCentered: true,
              onTap: (i) {
                setState(() => _index = i);
                _controller.animateTo(i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageTabPage extends StatelessWidget {
  const _ImageTabPage({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
