import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  bool _isLoading = false;

  /// 🔵 Google Login
  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);

    try {
      final user = await _auth.signInWithGoogle();

      /// ✅ เด้งไป Home ทันที
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google login failed")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [

              const Spacer(),

              Image.asset('assets/images/logo.png', height: 120),

              const SizedBox(height: 10),

              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5BA3D0),
                ),
              ),

              const SizedBox(height: 40),

              /// 🔵 GOOGLE LOGIN (เหลืออันเดียว)
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _googleLogin,
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 22,
                  ),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Log in with Google",
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}