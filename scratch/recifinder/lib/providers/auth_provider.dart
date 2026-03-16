import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  User? _user;
  bool _isLoading = false;
  bool _firebaseAvailable = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get firebaseAvailable => _firebaseAvailable;

  AuthProvider() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _auth!.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint('Firebase not available: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (!_firebaseAvailable || _auth == null) {
      throw Exception('Firebase authentication is not available');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    if (!_firebaseAvailable || _auth == null) {
      throw Exception('Firebase authentication is not available');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (!_firebaseAvailable || _auth == null || _googleSignIn == null) {
      throw Exception('Firebase authentication is not available');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth!.signInWithCredential(credential);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!_firebaseAvailable) {
      _user = null;
      notifyListeners();
      return;
    }

    await _auth!.signOut();
    await _googleSignIn!.signOut();
  }
}