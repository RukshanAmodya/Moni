import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Authentication failed';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}
