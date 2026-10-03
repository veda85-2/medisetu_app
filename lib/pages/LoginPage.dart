import 'package:flutter/material.dart';
import './signup_Page.dart';
import '../services/auth_service.dart';
import './Home_page.dart';
import '../doctor/doctor_profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = true;
  bool showPassword = false;
  bool isLoading = false;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================
  // LOGIN LOGIC
  // =========================

  Future<void> _handleLogin() async {
    final username = emailController.text.trim();
    final password = passwordController.text;

    // Check empty fields
    if (username.isEmpty || password.isEmpty) {
      _showMessage('Please enter username and password');
      return;
    }

    // Show loading
    setState(() {
      isLoading = true;
    });

    try {
      // Call Django login API
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      // Stop loading
      setState(() {
        isLoading = false;
      });

      // Check API result
      if (result['success'] == true) {
        _showMessage('Login successful');

        // Open dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MedicalDashboardScreen(),
          ),
        );
      } else {
        final message =
            result['message']?.toString() ??
            'Invalid username or password';

        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Unable to connect to server. Please check your connection.',
      );
    }
  }

  // =========================
  // SHOW MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF8FF),
              Color(0xFFF8FCFF),
              Color(0xFFDFFBFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top-left curved background
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD7F1FF),
                  ),
                ),
              ),

              // Bottom blue curved background
              Positioned(
                bottom: -110,
                left: -80,
                child: Container(
                  width: 430,
                  height: 220,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(220),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB9E5FF),
                        Color(0xFF74D9FF),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom-right turquoise curve
              Positioned(
                bottom: -100,
                right: -100,
                child: Container(
                  width: 270,
                  height: 190,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(180),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB4F5F3),
                        Color(0xFF48E1E0),
                      ],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/heart_logo.png',
                              width: 82,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Center(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Medi',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Color(0xFF173F70),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Setu',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Color(0xFF18B8C8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Center(
                            child: Text(
                              'One Platform. Complete Care.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6685A0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'Welcome back 👋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173F70),
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            'Sign in to your account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6685A0),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // USERNAME FIELD
                          // =========================

                          _inputField(
                            controller: emailController,
                            icon: Icons.person_outline,
                            hint: 'Username',
                          ),

                          const SizedBox(height: 12),

                          // =========================
                          // PASSWORD FIELD
                          // =========================

                          TextField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF173F70),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 17,
                                color: Color(0xFF6685A0),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword =
                                        !showPassword;
                                  });
                                },
                                icon: Icon(
                                  showPassword
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                  size: 17,
                                  color:
                                      const Color(0xFF6685A0),
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF91A8BC),
                              ),
                              filled: true,
                              fillColor:
                                  Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(7),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(7),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCEBF4),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(7),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2589E8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          // Remember me / Forgot password
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe =
                                              value ?? false;
                                        });
                                      },
                                      activeColor:
                                          const Color(0xFF2589E8),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize
                                              .shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF6685A0),
                                    ),
                                  ),
                                ],
                              ),

                              TextButton(
                                onPressed: () {
                                  // Forgot password logic
                                  // can be added later
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize
                                          .shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF2589E8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // LOGIN BUTTON
                          // =========================

                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : _handleLogin,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF287ED8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // OR
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color:
                                      const Color(0xFFE2EDF3),
                                ),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF8CA4B7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color:
                                      const Color(0xFFE2EDF3),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6685A0),
                                  ),
                                ),

                                const SizedBox(height: 2),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(0xFF18AFC1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD
  // =========================

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF173F70),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 17,
          color: const Color(0xFF6685A0),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF91A8BC),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFFDCEBF4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFF2589E8),
          ),
        ),
      ),
    );
  }
}