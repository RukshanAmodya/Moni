import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/moni_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerAnimationController;
  bool _isScanning = false;
  final TextEditingController _partnerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    _partnerIdController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _scannerAnimationController.repeat(reverse: true);

    // Simulate scan success after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false;
        });
        _scannerAnimationController.stop();
        _linkPartner('asha.partner@moni.com');
      }
    });
  }

  void _linkPartner(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Partner Found!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Do you want to link your Moni ledger with $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully linked with $email!'),
                  backgroundColor: const Color(0xFF8A72F6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A72F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Link Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final finance = Provider.of<FinanceProvider>(context);

    // If not authenticated, show premium placeholder requesting login
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: MoniTheme.background,
        appBar: AppBar(
          title: const Text('Moni Profile', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: MoniTheme.darkText,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EFFC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 64, color: Color(0xFF8A72F6)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Authentication Required',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: MoniTheme.darkText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in to view your profile, access your unique QR Code, and invite partners to co-manage ledgers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MoniTheme.mutedText, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A72F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign In / Register',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userEmail = auth.user?.email ?? 'user@moni.com';
    final userUid = auth.user?.uid ?? 'MONI-7729-XX';

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Moni Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: MoniTheme.premiumCardDecoration,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFF0EFFC),
                    child: Text(
                      userEmail[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8A72F6)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userEmail,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Moni Premium Account',
                          style: TextStyle(color: Color(0xFF8A72F6), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code Display Section
            const Text(
              'My QR Identity Code',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: MoniTheme.premiumCardDecoration,
              child: Column(
                children: [
                  // Beautiful Dynamic Painted QR Code Grid
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF8A72F6).withOpacity(0.15), width: 2),
                      ),
                      child: CustomPaint(
                        painter: QRPainter(hashData: userUid),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UID: $userUid',
                    style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let your partner scan this QR code to connect budgets instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: MoniTheme.mutedText, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scan Partner QR Code / Collaborative Action Section
            const Text(
              'Link Partner Ledger',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: MoniTheme.premiumCardDecoration,
              child: Column(
                children: [
                  if (_isScanning) ...[
                    // Scanning View Simulator
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _scannerAnimationController,
                            builder: (context, child) {
                              return Positioned(
                                top: _scannerAnimationController.value * 140 + 10,
                                child: Container(
                                  width: 180,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A72F6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8A72F6).withOpacity(0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Align partner\'s QR code within the frame...', style: TextStyle(fontSize: 12, color: MoniTheme.mutedText)),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startScanning,
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Colors.white),
                          label: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A72F6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                title: const Text('Enter Partner UID', style: TextStyle(fontWeight: FontWeight.w900)),
                                content: TextField(
                                  controller: _partnerIdController,
                                  decoration: InputDecoration(
                                    hintText: 'MONI-XXXX-XX',
                                    filled: true,
                                    fillColor: const Color(0xFFF6F5FD),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _linkPartner(_partnerIdController.text);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A72F6)),
                                    child: const Text('Connect', style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.keyboard_rounded, size: 18, color: Color(0xFF8A72F6)),
                          label: const Text('Enter Code', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A72F6))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8A72F6), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw a simulated high fidelity QR Code pattern
class QRPainter extends CustomPainter {
  final String hashData;
  QRPainter({required this.hashData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E1E24);

    // Draw the 3 large corner anchor squares (Standard QR anchors)
    _drawAnchor(canvas, const Offset(0, 0), paint);
    _drawAnchor(canvas, Offset(size.width - 40, 0), paint);
    _drawAnchor(canvas, Offset(0, size.height - 40), paint);

    // Generate pseudo-random matrix blocks based on the hash data
    final random = Random(hashData.hashCode);
    const int gridCount = 21;
    final double cellSize = size.width / gridCount;

    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        // Skip corner anchor areas to avoid overlapping standard squares
        if ((r < 7 && c < 7) || (r < 7 && c >= gridCount - 7) || (r >= gridCount - 7 && c < 7)) {
          continue;
        }

        // Random fill cells based on seed
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize - 0.5, cellSize - 0.5),
            paint,
          );
        }
      }
    }
  }

  void _drawAnchor(Canvas canvas, Offset offset, Paint paint) {
    // Outer boundary square
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, 40, 40), paint);
    // Inner white separator
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(offset.dx + 5, offset.dy + 5, 30, 30), whitePaint);
    // Center filled block
    canvas.drawRect(Rect.fromLTWH(offset.dx + 10, offset.dy + 10, 20, 20), paint);
  }

  @override
  bool shouldRepaint(covariant QRPainter oldDelegate) => oldDelegate.hashData != hashData;
}
