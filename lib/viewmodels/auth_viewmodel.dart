import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    // Listen for auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
   Future<void> _forceSignOut() async {
    try {
      await _authService.signOut();
    } catch (_) {}
   }

 Future<void> signInWithGoogle() async {
  try {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.signInWithGoogle();

    if (_user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Google login cancelled.',
      );
    }

    // Normalize email
    final normalizedEmail = _user!.email!.trim().toLowerCase();

    // Check Firestore allowlist
    final allowedDoc = await FirebaseFirestore.instance
        .collection('allowed_emails')
        .doc(normalizedEmail)
        .get();

    if (!allowedDoc.exists) {
      await _forceSignOut();
      throw FirebaseAuthException(
        code: 'email-not-allowed',
        message: 'This email is not allowed to sign in.',
      );
    }

  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }
}
