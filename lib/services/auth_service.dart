import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 🔵 GOOGLE LOGIN
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user == null) return null;

      return userCredential.user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// 🔴 LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}