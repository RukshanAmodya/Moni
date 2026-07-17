import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/moni_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Mobile Scanner Camera View
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_hasScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  setState(() {
                    _hasScanned = true;
                  });
                  _scannerController.stop();
                  Navigator.pop(context, rawValue);
                  break;
                }
              }
            },
          ),

          // Custom Scanner Framing Overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.55),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Glowing Scan Borders
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF8A72F6), width: 3.5),
            ),
          ),

          // Animated Scanning Line
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 - 125 + (_animationController.value * 230) + 10,
                child: Container(
                  width: 230,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A72F6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A72F6).withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Positioned(
            bottom: 60,
            child: Column(
              children: [
                Text(
                  'Align QR Code Inside Box',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Camera will automatically detect the identity QR',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
