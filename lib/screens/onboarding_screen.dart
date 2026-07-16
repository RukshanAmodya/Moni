import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/moni_theme.dart';
import 'navigation_holder.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Moni',
      'description': 'Welcome to Moni. Keep track of daily expenses, manage wallets, and save money effortlessly with an elegant design.',
    },
    {
      'title': 'Your Finances in One Place',
      'description': 'Get the big picture on all your money. Connect your wallets, track cash flow, and manage your budget smarter.',
    },
    {
      'title': 'Invite Other People',
      'description': 'Connect all your accounts with your friends or family. Add savings, credit cards, bank accounts, and more.',
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('moni_onboarding_seen', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationHolder()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPurple = Color(0xFF8A72F6); // Premium purple from mockup

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5E7FD), // Soft purple/lavender
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.60],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Page View for Graphic/Illustrations
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildIllustrationForPage(index);
                  },
                ),
              ),

              // Bottom card with text details & button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      _currentPage == 0 ? '' : _onboardingData[_currentPage]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: MoniTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    SizedBox(
                      height: 60,
                      child: Text(
                        _currentPage == 0 ? '' : _onboardingData[_currentPage]['description']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MoniTheme.mutedText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Slide Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index ? brandPurple : brandPurple.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Navigation Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next Step',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationForPage(int index) {
    switch (index) {
      case 0:
        // Screen 1: Splash screen with the logo and the text "Moni"
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF8A72F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Text(
                'Moni',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8A72F6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      case 1:
        // Screen 2: Centered purple logo surrounded by 6 category icons floating in a circle
        final List<Map<String, dynamic>> floatingIcons = [
          {'icon': Icons.local_grocery_store, 'color': Colors.green},
          {'icon': Icons.home_rounded, 'color': Colors.purple},
          {'icon': Icons.campaign_rounded, 'color': Colors.orange},
          {'icon': Icons.flight_takeoff_rounded, 'color': Colors.blue},
          {'icon': Icons.directions_car_rounded, 'color': Colors.lightBlue},
          {'icon': Icons.menu_book_rounded, 'color': Colors.deepPurple},
        ];

        return Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner center circle logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.wallet, color: Color(0xFF8A72F6), size: 36),
                  ),
                ),
                // Floating icons positioned in a circle
                ...List.generate(6, (idx) {
                  final angle = (idx * 2 * pi) / 6 - (pi / 2);
                  final double x = 100 * cos(angle);
                  final double y = 100 * sin(angle);
                  final item = floatingIcons[idx];

                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 20),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      case 2:
        // Screen 3: List of clean contact cards (Ethan Cole, Alex Carter, Maya Bennett)
        final List<Map<String, String>> contacts = [
          {'name': 'Ethan Cole', 'email': 'ethancoleux@gmail.com'},
          {'name': 'Alex Carter', 'email': 'alex.carter@email.com'},
          {'name': 'Maya Bennett', 'email': 'maya.bennett@email.com'},
        ];

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: contacts.map((contact) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF8A72F6).withOpacity(0.12),
                        child: Text(
                          contact['name']![0],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A72F6)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              contact['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MoniTheme.darkText),
                            ),
                            Text(
                              contact['email']!,
                              style: const TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: MoniTheme.darkText,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: const Text('Invite', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
