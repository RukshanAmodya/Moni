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
      'title': 'TURN INCOME INTO\nSMART INVESTMENTS',
      'description': 'Welcome to Moni. Keep track of daily expenses, manage wallets, and save money effortlessly with an elegant design.',
    },
    {
      'title': 'TRACK DAILY\nEXPENSES IN A CLICK',
      'description': 'Log income or expense instantly. Categorize them into Food, Bills, Shopping, or create custom categories in Settings.',
    },
    {
      'title': 'SET BUDGETS &\nWARNING NOTIFICATIONS',
      'description': 'Set monthly budget limits for each category. Moni alerts you with warning badges if you spend above 80% of your limit.',
    },
    {
      'title': 'SECURE BIOMETRICS\n& CLOUD SYNCING',
      'description': 'Activate Fingerprint/PIN lock to secure financial data. Sign in with Firebase to automatically sync and backup your data.',
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
    return Scaffold(
      backgroundColor: MoniTheme.sageGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Title
            Text(
              'MONI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 20),

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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Interactive/dynamic vector shapes representing features
                            _buildIllustrationForPage(index),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom card with text details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 48),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  SizedBox(
                    height: 80,
                    child: Text(
                      _onboardingData[_currentPage]['title']!,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 26,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  SizedBox(
                    height: 70,
                    child: Text(
                      _onboardingData[_currentPage]['description']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MoniTheme.blackAccent,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.center,
                            child: Text(
                              _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next Step',
                              style: const TextStyle(
                                color: MoniTheme.blackAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                Icon(Icons.chevron_right, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationForPage(int index) {
    switch (index) {
      case 0:
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 1; i <= 2; i++)
              Container(
                width: i * 110.0,
                height: i * 110.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                ),
              ),
            CustomPaint(
              size: const Size(180, 80),
              painter: OnboardingChartPainter(),
            ),
          ],
        );
      case 1:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 64),
              SizedBox(height: 12),
              Text(
                'LKR 1,500.00 Saved',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
      case 2:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 64),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Food Budget: 82% Used!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_done_outlined, color: Colors.white, size: 64),
              SizedBox(height: 12),
              Text(
                'Secure Sync Enabled',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
    }
  }
}

class OnboardingChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paintLine);
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.15), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
