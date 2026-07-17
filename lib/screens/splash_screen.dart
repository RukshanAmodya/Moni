import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import 'navigation_holder.dart';
import 'onboarding_screen.dart';
import 'pin_lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _particleController;
  late final AnimationController _pulseController;

  // ─── Animations ──────────────────────────────────────────────────────────
  late final Animation<double> _bgOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _pulseScale;

  // App version string (matches pubspec.yaml)
  static const String _appVersion = 'v1.1.0';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Background fade-in
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bgOpacity = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);

    // Logo scale + fade + slide
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Brand text slide-up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Logo glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimations() async {
    // Stagger the animations beautifully
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Wait until all animations settle, then navigate
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('moni_onboarding_seen') ?? false;

    if (!mounted) return;

    final finance = Provider.of<FinanceProvider>(context, listen: false);

    Widget nextScreen;
    if (finance.pinEnabled) {
      nextScreen = PinLockScreen(
        isSettingPin: false,
        onSuccess: (pinContext) {
          Navigator.of(pinContext).pushReplacement(
            MaterialPageRoute(
              builder: (_) => hasSeenOnboarding
                  ? const NavigationHolder()
                  : const OnboardingScreen(),
            ),
          );
        },
      );
    } else {
      nextScreen = hasSeenOnboarding
          ? const NavigationHolder()
          : const OnboardingScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _bgOpacity,
        child: Stack(
          children: [
            // ── Gradient Background ───────────────────────────────────────
            _buildGradientBackground(size),

            // ── Floating Decorative Circles ───────────────────────────────
            _buildFloatingOrbs(size),

            // ── Floating Particles ────────────────────────────────────────
            _buildParticles(size),

            // ── Main Content ──────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Logo with glow ring + pulse
                  SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _buildLogoWidget(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Brand name & tagline
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: _buildBrandText(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Version Badge (bottom) ────────────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: _buildVersionBadge(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widget Builders ─────────────────────────────────────────────────────

  Widget _buildGradientBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0EEFF), // very light lavender
            Color(0xFFFFFFFF), // white
            Color(0xFFEEF4FF), // soft blue-white
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingOrbs(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (_, __) {
        final t = _particleController.value;
        return Stack(
          children: [
            // Top-left large orb
            Positioned(
              top: -60 + math.sin(t * 2 * math.pi) * 15,
              left: -60 + math.cos(t * 2 * math.pi) * 10,
              child: _glowOrb(200, MoniTheme.sageGreen.withOpacity(0.12)),
            ),
            // Bottom-right large orb
            Positioned(
              bottom: -80 + math.sin((t + 0.5) * 2 * math.pi) * 20,
              right: -80 + math.cos((t + 0.3) * 2 * math.pi) * 10,
              child: _glowOrb(260, MoniTheme.pastelBlue.withOpacity(0.09)),
            ),
            // Center-right medium orb
            Positioned(
              top: size.height * 0.35 + math.sin(t * 2 * math.pi + 1) * 12,
              right: 30 + math.cos(t * 2 * math.pi + 0.5) * 8,
              child: _glowOrb(100, MoniTheme.pastelPurple.withOpacity(0.15)),
            ),
            // Left medium orb
            Positioned(
              bottom: size.height * 0.28 + math.sin((t + 0.7) * 2 * math.pi) * 10,
              left: 20 + math.cos((t + 0.2) * 2 * math.pi) * 6,
              child: _glowOrb(80, MoniTheme.pastelGreen.withOpacity(0.12)),
            ),
          ],
        );
      },
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildParticles(Size size) {
    final List<_ParticleData> particles = [
      _ParticleData(0.15, 0.20, 4, MoniTheme.sageGreen, 0.0),
      _ParticleData(0.80, 0.15, 6, MoniTheme.pastelBlue, 0.2),
      _ParticleData(0.90, 0.55, 3, MoniTheme.pastelPink, 0.5),
      _ParticleData(0.10, 0.72, 5, MoniTheme.pastelPurple, 0.7),
      _ParticleData(0.55, 0.88, 4, MoniTheme.pastelGreen, 0.3),
      _ParticleData(0.70, 0.40, 3, MoniTheme.pastelOrange, 0.8),
      _ParticleData(0.35, 0.10, 5, MoniTheme.sageGreen, 0.6),
    ];

    return AnimatedBuilder(
      animation: _particleController,
      builder: (_, __) {
        return Stack(
          children: particles.map((p) {
            final t = (_particleController.value + p.phase) % 1.0;
            final floatY = math.sin(t * 2 * math.pi) * 18;
            final floatX = math.cos(t * 2 * math.pi * 0.7) * 10;
            final opacity = (math.sin(t * math.pi).clamp(0.0, 1.0)) * 0.6 + 0.1;

            return Positioned(
              left: size.width * p.relX + floatX,
              top: size.height * p.relY + floatY,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: p.radius,
                  height: p.radius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.color.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withOpacity(0.4),
                        blurRadius: p.radius * 1.5,
                        spreadRadius: p.radius * 0.3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLogoWidget() {
    return ScaleTransition(
      scale: _pulseScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring (animated)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              return Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MoniTheme.sageGreen.withOpacity(
                          0.22 + _pulseController.value * 0.1),
                      MoniTheme.sageGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // Inner circle background
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MoniTheme.sageGreen,
                  const Color(0xFF6B4FE0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MoniTheme.sageGreen.withOpacity(0.45),
                  blurRadius: 35,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // "M" letter logo
          const Text(
            'M',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 68,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
              shadows: [
                Shadow(
                  blurRadius: 20,
                  color: Colors.black26,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandText() {
    return Column(
      children: [
        // App name
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF8A72F6),
              Color(0xFF4FA0FF),
            ],
          ).createShader(bounds),
          child: const Text(
            'Moni',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked by shader
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Tagline
        FadeTransition(
          opacity: _taglineOpacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: MoniTheme.sageGreen.withOpacity(0.08),
              border: Border.all(
                color: MoniTheme.sageGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Text(
              'Smart Money Manager',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MoniTheme.sageGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionBadge() {
    return Column(
      children: [
        // Loading dots
        _buildLoadingDots(),
        const SizedBox(height: 16),
        Text(
          _appVersion,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: MoniTheme.mutedText,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (_particleController.value * 3 - i).clamp(0.0, 1.0);
            final scale = math.sin(t * math.pi).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MoniTheme.sageGreen
                        .withOpacity(0.3 + scale * 0.7),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Particle Data Model ──────────────────────────────────────────────────────

class _ParticleData {
  final double relX;
  final double relY;
  final double radius;
  final Color color;
  final double phase;

  const _ParticleData(
      this.relX, this.relY, this.radius, this.color, this.phase);
}
