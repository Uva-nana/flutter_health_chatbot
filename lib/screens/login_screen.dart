import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/profile_service.dart';
import '../models/diet_profile.dart';
import 'home_screen.dart';
import 'diet_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final user = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in cancelled or failed.')),
      );
      return;
    }

    // Load profile from Firestore or local storage
    final firestoreService = FirestoreService();
    DietProfile? profile = await firestoreService.loadProfile() ??
        await ProfileService().loadProfile();

    if (!mounted) return;

    if (profile == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DietProfileScreen(isFirstSetup: true),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialProfile: profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 54,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Health Assistant',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your personal AI-powered nutrition\nand wellness companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              // Features
              _featureRow(Icons.chat_bubble_outline, 'Personalized AI health chat'),
              const SizedBox(height: 12),
              _featureRow(Icons.monitor_weight_outlined, 'BMI Calculator'),
              const SizedBox(height: 12),
              _featureRow(Icons.person_outline, 'Custom diet profile'),
              const SizedBox(height: 12),
              _featureRow(Icons.history, 'Chat history saved to cloud'),
              const Spacer(flex: 2),
              // Google Sign In button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.green.shade600,
                        ),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _signInWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 22,
                              height: 22,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.g_mobiledata,
                                size: 28,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'By continuing, you agree to our terms of service',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green.shade600, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}
