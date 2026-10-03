
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String onboardingKey = 'onboarding_completed';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(onboardingKey) ?? false;
  }

  static Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(onboardingKey, true);
  }

  // Useful while testing.
  // Call this only when you want onboarding to appear again.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(onboardingKey);
  }
}

