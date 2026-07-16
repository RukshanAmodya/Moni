import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/biometric_service.dart';
import '../theme/moni_theme.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSettingPin;
  final VoidCallback? onSuccess;

  const PinLockScreen({
    super.key,
    this.isSettingPin = false,
    this.onSuccess,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final BiometricService _biometricService = BiometricService();
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    // Auto-prompt biometrics if unlocking and enabled
    if (!widget.isSettingPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkBiometrics();
      });
    }
  }

  void _checkBiometrics() async {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    if (finance.biometricEnabled) {
      final available = await _biometricService.isBiometricAvailable();
      if (available) {
        final authenticated = await _biometricService.authenticate();
        if (authenticated && mounted) {
          if (widget.onSuccess != null) widget.onSuccess!();
        }
      }
    }
  }

  void _onNumberTap(int val) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += val.toString();
        _errorMessage = '';
      });
      if (_enteredPin.length == 4) {
        // Let UI finish rendering before processing to avoid keyboard freeze lag
        Future.delayed(const Duration(milliseconds: 150), () {
          _handlePinSubmit();
        });
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _handlePinSubmit() async {
    if (!mounted) return;
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    if (widget.isSettingPin) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _confirmPin) {
          await provider.setPin(_enteredPin);
          if (widget.onSuccess != null) widget.onSuccess!();
        } else {
          setState(() {
            _enteredPin = '';
            _confirmPin = '';
            _isConfirming = false;
            _errorMessage = 'PINs do not match. Try again.';
          });
        }
      }
    } else {
      final isValid = await provider.verifyPin(_enteredPin);
      if (isValid) {
        if (widget.onSuccess != null) widget.onSuccess!();
      } else {
        _failedAttempts++;
        if (provider.selfDestructEnabled && _failedAttempts >= 5) {
          await provider.wipeAllData();
          setState(() {
            _enteredPin = '';
            _failedAttempts = 0;
            _errorMessage = 'Wiped all data due to 5 failed PIN attempts!';
          });
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'Incorrect PIN. Attempt $_failedAttempts/5';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = 'Enter PIN';
    if (widget.isSettingPin) {
      titleText = _isConfirming ? 'Confirm PIN' : 'Create PIN';
    }

    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'MONI SECURE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              titleText,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            // Pin indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? MoniTheme.sageGreen : Colors.grey.shade300,
                    border: Border.all(
                      color: isFilled ? MoniTheme.sageGreen : Colors.transparent,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            const Spacer(),
            // Numeric Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    // Biometric quick trigger if enabled
                    if (!widget.isSettingPin && provider.biometricEnabled) {
                      return IconButton(
                        onPressed: _checkBiometrics,
                        icon: const Icon(Icons.fingerprint, size: 36, color: MoniTheme.sageGreen),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  if (index == 11) {
                    return IconButton(
                      onPressed: _onBackspace,
                      icon: const Icon(Icons.backspace_outlined, size: 28, color: MoniTheme.darkText),
                    );
                  }

                  int number = index == 10 ? 0 : index + 1;
                  return InkWell(
                    onTap: () => _onNumberTap(number),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        number.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MoniTheme.darkText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
