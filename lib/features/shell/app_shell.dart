import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../home/home_screen.dart';
import '../market/marketplace_home_screen.dart';
import '../profile/profile_screen.dart';
import '../scan/scan_home_screen.dart';

/// Icon-first bottom nav, max 4 items, per Orynta_Brand_Guide.md §6.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ScanHomeScreen(),
    MarketplaceHomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: strings('navHome'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt_rounded),
            label: strings('navScan'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront_rounded),
            label: strings('navMarket'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: strings('navProfile'),
          ),
        ],
      ),
    );
  }
}
