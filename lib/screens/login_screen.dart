import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;

  const LoginScreen({super.key, this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final finance = Provider.of<FinanceProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool success;
      if (_isSignUp) {
        success = await auth.signUp(email, password);
      } else {
        success = await auth.signIn(email, password);
      }

      if (success) {
        if (!_isSignUp) {
          // On Login, automatically restore backed up transactions from Firestore
          await finance.syncFromCloud();
        } else {
          // On Register, push local transactions up to cloud
          await finance.syncToCloud();
        }

        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          Navigator.pop(context);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Authentication Error'),
            content: Text(auth.errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: MoniTheme.sageGreen)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: MoniTheme.sageGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MONI CLOUD SYNC',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 3,
                          fontWeight: FontWeight.w800,
                          color: MoniTheme.sageGreen,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Create Cloud Account' : 'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: MoniTheme.sageGreen, width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your email';
                      if (!val.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: MoniTheme.sageGreen, width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your password';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MoniTheme.blackAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Sign In',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Login/SignUp
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(
                      _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                      style: const TextStyle(color: MoniTheme.sageGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
