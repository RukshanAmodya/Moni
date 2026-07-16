import 'package:flutter/material.dart';
import '../theme/moni_theme.dart';
import 'navigation_holder.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoniTheme.sageGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Text(
              'MONI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 30),
            // Graphic Area (Minimalist Wealth Graph / Illustration)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background concentric circles
                        for (int i = 1; i <= 3; i++)
                          Container(
                            width: i * 80.0,
                            height: i * 80.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.5,
                              ),
                            ),
                          ),
                        // Clean line chart representing growing wealth
                        CustomPaint(
                          size: const Size(200, 100),
                          painter: OnboardingChartPainter(),
                        ),
                        // Floating Glassmorphic balance card
                        Positioned(
                          top: 40,
                          right: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: MoniTheme.sageGreen,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '+ LKR 45,000',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: MoniTheme.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Info Card (Similar to the white container in Screen 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 48),
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
                  Text(
                    'TURN INCOME INTO\nSMART INVESTMENTS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage your money smartly, keep track of daily expenses, and achieve your saving goals effortlessly.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 36),
                  // Button "Get Started" (Pill with nested arrow icon)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const NavigationHolder(),
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MoniTheme.blackAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.center,
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                color: MoniTheme.blackAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
}

class OnboardingChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintShadow = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 10
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

    // Draw shadow first
    canvas.drawPath(path, paintShadow);
    // Draw foreground line
    canvas.drawPath(path, paintLine);

    // Draw end indicator dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.15), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
