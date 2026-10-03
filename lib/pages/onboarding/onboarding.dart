
import 'package:flutter/material.dart';

import '../appointment/appointment.dart';
import '../onboarding/onboarding_service.dart';
import '../LoginPage.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  // ==========================================================
  // FINISH ONBOARDING
  // ==========================================================

  Future<void> _finishOnboarding(
    BuildContext context,
  ) async {
    await OnboardingService.complete();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFEAF7FF),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 430,
            ),

            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Column(
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Image.asset(
                        'assets/doctor1.png',
                        width: 330,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // ==================================================
                  // TEXT
                  // ==================================================

                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment:
                          Alignment.topLeft,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          RichText(
                            text:
                                const TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Find the right\n',
                                  style:
                                      TextStyle(
                                    fontSize: 40,
                                    height: 1.05,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Color(
                                      0xFF123E68,
                                    ),
                                  ),
                                ),

                                TextSpan(
                                  text:
                                      'doctor',
                                  style:
                                      TextStyle(
                                    fontSize: 40,
                                    height: 1.05,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Color(
                                      0xFF079DBD,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Search specialists and hospitals\n'
                            'easily, based on your needs.',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.45,
                              fontWeight:
                                  FontWeight.w500,
                              color:
                                  Color(
                                0xFF6685A0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // DOTS
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      _dot(true),
                      _dot(false),
                      _dot(false),
                    ],
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      TextButton(
                        onPressed: () =>
                            _finishOnboarding(
                          context,
                        ),

                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color:
                                Color(
                              0xFF2589E8,
                            ),
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const AppointmentPage(),
                            ),
                          );
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2589E8,
                          ),

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Text(
                              'Next',
                              style:
                                  TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            SizedBox(
                              width: 4,
                            ),

                            Icon(
                              Icons
                                  .arrow_forward,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DOT
  // ==========================================================

  static Widget _dot(
    bool active,
  ) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),

      width: active ? 7 : 6,
      height: active ? 7 : 6,

      decoration:
          BoxDecoration(
        shape: BoxShape.circle,

        color: active
            ? const Color(
                0xFF2589E8,
              )
            : const Color(
                0xFFBFDCEF,
              ),
      ),
    );
  }
}

