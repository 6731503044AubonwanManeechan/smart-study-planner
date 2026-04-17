import 'dart:async'; // ✅ สำคัญ
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Email & Password Login
  Future<User?> signIn(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// 🔹 Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);

      return userCredential.user;
    } catch (e) {
      print("Google sign in error: $e");
      rethrow;
    }
  }
}

/// ⏰ Timer
Timer? eyeRestTimer;

/// 📩 ส่ง Email
Future sendEmail(String toEmail, String message) async {
  await http.post(
    Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
    headers: {
      'origin': 'http://localhost',
      'Content-Type': 'application/json',
    },
    body: '''
    {
      "service_id":"service_r0lk63j",
      "template_id":"template_koi2o7y",
      "user_id":"0GGwZFY38hZxVHT8O",
      "template_params":{
      "to_email":"$toEmail",
      "message":"$message"
      }
    }
    ''',
  );
}

/// ▶️ เริ่ม Timer
void startEyeRestTimer(User user) {
  stopEyeRestTimer();

  eyeRestTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
    await sendEmail(user.email!, "ถึงเวลาพักสายตาแล้ว 👀");
  });
}

/// ⛔ หยุด Timer
void stopEyeRestTimer() {
  eyeRestTimer?.cancel();
}