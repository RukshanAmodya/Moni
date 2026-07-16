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

  void _showAddTransactionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const AddTransactionDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .chain(CurveTween(curve: Curves.easeOutQuint))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryActive = Color(0xFF8A72F6); // Premium purple from design

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: Stack(
        children: [
          // Screen content area
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 95),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ),

          // Custom Premium White Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavItem(0, Icons.home_filled, 'Home', primaryActive)),
                  Expanded(child: _buildNavItem(1, Icons.swap_horiz_rounded, 'Ledger', primaryActive)),
                  
                  // Center Floating Action Button
                  GestureDetector(
                    onTap: _showAddTransactionDialog,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: MoniTheme.blackAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),

                  Expanded(child: _buildNavItem(2, Icons.analytics_rounded, 'Analytics', primaryActive)),
                  Expanded(child: _buildNavItem(3, Icons.person_rounded, 'Settings', primaryActive)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor) {
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
            color: isSelected ? activeColor : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? activeColor : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
