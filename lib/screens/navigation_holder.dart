import 'package:flutter/material.dart';
import '../theme/moni_theme.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'plan_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart'; // to open the AddTransactionDialog
import '../widgets/currency_selector_sheet.dart';
import '../providers/finance_provider.dart';
import 'package:provider/provider.dart';

class NavigationHolder extends StatefulWidget {
  const NavigationHolder({super.key});

  @override
  State<NavigationHolder> createState() => NavigationHolderState();
}

class NavigationHolderState extends State<NavigationHolder> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const PlanScreen(),
    const SettingsScreen(),
  ];

  void _showAddTransactionDialog() {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    if (finance.currency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a currency first!')),
      );
      CurrencySelectorSheet.show(context);
      return;
    }

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
    const Color primaryActive = Color(0xFF8A72F6); // Brand purple
    const Color lightPurpleFAB = Color(0xFFE5E2FF); // Light purple circle FAB

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
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home', primaryActive)),
                  Expanded(child: _buildNavItem(1, Icons.bar_chart_rounded, 'Report', primaryActive)),
                  
                  // Center Floating Action Button (light purple, matching mockup)
                  GestureDetector(
                    onTap: _showAddTransactionDialog,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: lightPurpleFAB,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: primaryActive, size: 28),
                    ),
                  ),

                  Expanded(child: _buildNavItem(2, Icons.track_changes_rounded, 'Plan', primaryActive)),
                  Expanded(child: _buildNavItem(3, Icons.settings_rounded, 'Settings', primaryActive)),
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
