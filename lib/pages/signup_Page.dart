import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import './LoginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int selectedRole = 0;

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool agreeTerms = false;
  bool isLoading = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final specializationController = TextEditingController();
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    specializationController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      _showMessage('Please enter your full name');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage('Please enter your mobile number');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (selectedRole == 0) {
      if (dobController.text.isEmpty) {
        _showMessage('Please select your date of birth');
        return;
      }

      if (selectedGender == null) {
        _showMessage('Please select your gender');
        return;
      }
    }

    if (selectedRole == 1) {
      if (specializationController.text.trim().isEmpty) {
        _showMessage('Please enter your specialization');
        return;
      }

      if (qualificationController.text.trim().isEmpty) {
        _showMessage('Please enter your qualification');
        return;
      }

      if (experienceController.text.trim().isEmpty) {
        _showMessage('Please enter your experience');
        return;
      }
    }

    if (password.isEmpty) {
      _showMessage('Please enter a password');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    if (!agreeTerms) {
      _showMessage('Please agree to the Terms & Conditions');
      return;
    }

    final nameParts = name.split(RegExp(r'\s+'));

    final firstName = nameParts.first;
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final username = email.split('@').first;

    String role;

    if (selectedRole == 0) {
      role = 'PATIENT';
    } else if (selectedRole == 1) {
      role = 'DOCTOR';
    } else {
      role = 'ADMIN';
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await AuthService.register(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result['success'] == true) {
        _showMessage('Account created successfully');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        final message =
            result['message']?.toString() ?? 'Registration failed';

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
      backgroundColor: const Color(0xFF202020),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF7FCFF),
                Color(0xFFEAF7FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -80,
                right: -80,
                child: Container(
                  width: 270,
                  height: 190,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB8F5F4),
                        Color(0xFF5DDDDD),
                      ],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    25,
                    15,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Color(0xFF42617C),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123E68),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Join MediSetu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0C1E2C),
                        ),
                      ),

                      const Text(
                        'and take control of your health journey.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6891B4),
                        ),
                      ),

                      const SizedBox(height: 30),

                      _roleSelector(),

                      const SizedBox(height: 15),

                      _inputField(
                        controller: nameController,
                        icon: Icons.person_outline,
                        hint: 'Full Name',
                      ),

                      const SizedBox(height: 15),

                      _inputField(
                        controller: phoneController,
                        icon: Icons.phone_android_outlined,
                        hint: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 15),

                      _inputField(
                        controller: emailController,
                        icon: Icons.email_outlined,
                        hint: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 15),

                      if (selectedRole == 0) ...[
                        _inputField(
                          controller: dobController,
                          icon: Icons.calendar_today_outlined,
                          hint: 'Date of Birth',
                          readOnly: true,
                          onTap: _selectDate,
                        ),

                        const SizedBox(height: 15),

                        _genderField(),

                        const SizedBox(height: 15),
                      ],

                      if (selectedRole == 1) ...[
                        _inputField(
                          controller: specializationController,
                          icon: Icons.medical_services_outlined,
                          hint: 'Specialization',
                        ),

                        const SizedBox(height: 15),

                        _inputField(
                          controller: qualificationController,
                          icon: Icons.school_outlined,
                          hint: 'Qualification',
                        ),

                        const SizedBox(height: 15),

                        _inputField(
                          controller: experienceController,
                          icon: Icons.work_history_outlined,
                          hint: 'Experience (Years)',
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 15),
                      ],

                      if (selectedRole == 2) ...[
                        const SizedBox(height: 5),
                      ],

                      _passwordField(
                        controller: passwordController,
                        hint: 'Password',
                        showPassword: showPassword,
                        onToggle: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      _passwordField(
                        controller: confirmPasswordController,
                        hint: 'Confirm Password',
                        showPassword: showConfirmPassword,
                        onToggle: () {
                          setState(() {
                            showConfirmPassword =
                                !showConfirmPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: agreeTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreeTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF2589E8),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),

                          const SizedBox(width: 5),

                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6685A0),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF2589E8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\nand ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6685A0),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF2589E8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF287ED8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
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
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleSelector() {
    const roles = [
      'Patient',
      'Doctor',
      'Admin',
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EFF9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: List.generate(
          roles.length,
          (index) {
            final selected = selectedRole == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF287ED8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      roles[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF6685A0),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF123E68),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 19,
            color: const Color(0xFF6685A0),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF91A8BC),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFF2589E8),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF123E68),
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 19,
            color: Color(0xFF6685A0),
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              showPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF6685A0),
            ),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF91A8BC),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFF2589E8),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderField() {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.person_outline,
            size: 19,
            color: Color(0xFF6685A0),
          ),
          hintText: 'Gender',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF91A8BC),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFFD9EAF5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: Color(0xFF2589E8),
            ),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 18,
          color: Color(0xFF6685A0),
        ),
        items: const [
          DropdownMenuItem(
            value: 'Male',
            child: Text('Male'),
          ),
          DropdownMenuItem(
            value: 'Female',
            child: Text('Female'),
          ),
          DropdownMenuItem(
            value: 'Other',
            child: Text('Other'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (date != null) {
      setState(() {
        dobController.text =
            '${date.day}/${date.month}/${date.year}';
      });
    }
  }
}