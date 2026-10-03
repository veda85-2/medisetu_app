
import 'package:flutter/material.dart';

import 'pages/onboarding/splash_background.dart';
import 'pages/onboarding/onboarding.dart';
import 'pages/Home_page.dart';
import 'pages/onboarding/onboarding_service.dart';
import '../services/auth_service.dart';
import 'pages/LoginPage.dart';
// import 'Home_page.dart';

void main() {
  runApp(const MediSetuApp());
}

class MediSetuApp extends StatelessWidget {
  const MediSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediSetu',

      home: const SplashScreen(),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkOnboarding();
  }

 Future<void> _checkOnboarding() async {
  await Future.delayed(
    const Duration(seconds: 2),
  );

  if (!mounted) return;

  final bool completed =
      await OnboardingService.isCompleted();

  if (!mounted) return;

  if (!completed) {
    // New user → Onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      ),
    );
    return;
  }

  // Onboarding completed
  // Now check whether user is logged in
  final result = await AuthService.getMe();

  if (!mounted) return;

  if (result['success'] == true) {
    // User is already logged in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MedicalDashboardScreen(),
      ),
    );
  } else {
    // No valid login session
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(
            child: SplashBackground(),
          ),

          // Logo + title
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/heart_logo.png',
                  width: 250,
                ),

                const SizedBox(height: 12),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Medi',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF112C50),
                        ),
                      ),

                      TextSpan(
                        text: 'Setu',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF18B8C8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'One Platform. Complete Care.',
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        Color(0xFF6685A0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

