import 'package:flutter/material.dart';
import '../theme/moni_theme.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class NavigationHolder extends StatefulWidget {
  const NavigationHolder({super.key});

  @override
  State<NavigationHolder> createState() => _NavigationHolderState();
}

class _NavigationHolderState extends State<NavigationHolder> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: Stack(
        children: [
          // Screen content area
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90), // leave room for floating navigation bar
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ),
          // Custom Floating Bottom Navigation Bar (matches Apixer design)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: MoniTheme.blackAccent,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
                  _buildNavItem(1, Icons.swap_horiz_rounded, 'Transactions'),
                  _buildNavItem(2, Icons.analytics_outlined, 'Analytics'),
                  _buildNavItem(3, Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
