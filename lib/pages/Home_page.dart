import 'package:flutter/material.dart';

import '../doctor/doctor_find.dart';
import '../services/api_service.dart';
import '../models.dart';
import '../services/auth_service.dart';

import 'medical_records.dart';
import '../emergency.dart';
import 'profile.dart';
import 'prescriptions.dart';

import './appointment/appointment_details.dart';

class MedicalDashboardScreen extends StatefulWidget {
  const MedicalDashboardScreen({super.key});

  @override
  State<MedicalDashboardScreen> createState() =>
      _MedicalDashboardScreenState();
}

class _MedicalDashboardScreenState
    extends State<MedicalDashboardScreen> {
  int _selectedIndex = 0;

  String userName = 'User';
  bool isLoadingUser = true;

  final ApiService _apiService = ApiService();

  Map<String, dynamic>? upcomingAppointment;
  bool isLoadingAppointment = true;

  @override
  void initState() {
    super.initState();

    _loadUser();
    _loadUpcomingAppointment();
  }

  Future<void> _loadUser() async {
    final result = await AuthService.getMe();

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];

      setState(() {
        userName =
            data['first_name']?.toString().isNotEmpty == true
                ? data['first_name'].toString()
                : data['username']?.toString() ?? 'User';

        isLoadingUser = false;
      });
    } else {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  Future<void> _loadUpcomingAppointment() async {
    try {
      final appointments = await _apiService.fetchAppointments();

      if (!mounted) return;

      Map<String, dynamic>? latestAppointment;

      for (final appointment in appointments) {
        final status =
            appointment['status']?.toString().toUpperCase() ?? '';

        if (status == 'BOOKED') {
          latestAppointment = appointment;
          break;
        }
      }

      setState(() {
        upcomingAppointment = latestAppointment;
        isLoadingAppointment = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        upcomingAppointment = null;
        isLoadingAppointment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      body: SafeArea(
        child: FutureBuilder<List<Doctor>>(
          future: _apiService.fetchDoctor(
            search: null,
            specialty: null,
          ),

          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No doctors available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            final doctors = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                await _loadUpcomingAppointment();
                await _loadUser();
              },

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildSearchBar(),

                    const SizedBox(height: 20),

                    _buildEmergencyBanner(),

                    const SizedBox(height: 20),

                    _buildUpcomingAppointment(),

                    const SizedBox(height: 25),

                    _buildSectionTitle(
                      'What do you need today?',
                    ),

                    const SizedBox(height: 15),

                    _buildGridActions(),

                    const SizedBox(height: 28),

                    _buildHeaderWithAction(
                      'Available Doctors',
                      'View All',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FindDoctorPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    _buildDoctorsList(doctors),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,

          backgroundColor:
              const Color(0xFFE53935),

          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Good morning',

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Welcome, $userName',

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1D2433),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    '👋',
                    style:
                        TextStyle(fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              const Text(
                'How are you feeling today?',

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        InkWell(
          borderRadius:
              BorderRadius.circular(30),

          onTap: () {
            _showMessage(
              'No new notifications',
            );
          },

          child: Container(
            padding:
                const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.05),

                  blurRadius: 8,
                ),
              ],
            ),

            child: const Icon(
              Icons.notifications_none,
              size: 23,
              color:
                  Color(0xFF252B3A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onSubmitted: (value) {
        _showMessage(
          'Searching for "$value"',
        );
      },

      decoration: InputDecoration(
        hintText:
            'Search doctors, departments...',

        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),

        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(25),
          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(25),
          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(25),

          borderSide:
              const BorderSide(
            color:
                Color(0xFF3F51B5),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                const EmergencyPage(),
          ),
        );
      },

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color:
              const Color(0xFFE53935),

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(11),

              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.18),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Emergency / Quick Help',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Get immediate hospital assistance',

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    if (isLoadingAppointment) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.04),

              blurRadius: 10,

              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,

              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),

            SizedBox(width: 12),

            Text(
              'Loading appointment...',

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (upcomingAppointment == null) {
      return const SizedBox.shrink();
    }

    final appointment =
        upcomingAppointment!;

    final doctorDetail =
        appointment['doctor_detail']
            is Map
        ? Map<String, dynamic>.from(
            appointment['doctor_detail'],
          )
        : <String, dynamic>{};

    final doctorUser =
        doctorDetail['user'] is Map
        ? Map<String, dynamic>.from(
            doctorDetail['user'],
          )
        : <String, dynamic>{};

    final doctorName =
        doctorDetail['name']
            ?.toString()
            .trim()
            .isNotEmpty == true
        ? doctorDetail['name'].toString()
        : doctorUser['first_name']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true
            ? '${doctorUser['first_name']} ${doctorUser['last_name'] ?? ''}'
                .trim()
            : 'Doctor';

    final specialty =
        doctorDetail['specialization']
            ?.toString()
            .trim()
            .isNotEmpty == true
        ? doctorDetail['specialization']
            .toString()
        : doctorDetail['specialty']
                ?.toString() ??
            'Medical Specialist';

    final date =
        appointment['appointment_date']
            ?.toString() ??
        '';

    final time =
        appointment['appointment_time']
            ?.toString() ??
        '';

    final status =
        appointment['status']
            ?.toString()
            .toUpperCase() ??
        'BOOKED';

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color:
                    Color(0xFF3F51B5),
                size: 22,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Upcoming Appointment',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1D2433),
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.green
                      .withValues(
                          alpha: 0.1),

                  borderRadius:
                      BorderRadius
                          .circular(20),
                ),

                child: Text(
                  status,

                  style:
                      const TextStyle(
                    color:
                        Colors.green,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(
                radius: 25,

                backgroundColor:
                    const Color(
                        0xFFE8EAF6),

                child: const Icon(
                  Icons.person,
                  color:
                      Color(0xFF3F51B5),
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      doctorName,

                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF252B3A),
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      specialty,

                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child:
                    _appointmentInfo(
                  Icons.calendar_today,
                  date,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    _appointmentInfo(
                  Icons.access_time,
                  time,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,

            child:
                ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentDetailsPage(
                      appointment:
                          appointment,
                    ),
                  ),
                );

                _loadUpcomingAppointment();
              },

              icon: const Icon(
                Icons.visibility_outlined,
              ),

              label: const Text(
                'View Appointment',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                        0xFF3F51B5),

                foregroundColor:
                    Colors.white,

                elevation: 0,

                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 13,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentInfo(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF6F8FC),

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF3F51B5),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              text,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
                color:
                    Color(0xFF252B3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D2433),
      ),
    );
  }

  Widget _buildGridActions() {
    final items = [
      {
        'title': 'Find Doctor',
        'icon': Icons.person_search,
        'color': Colors.blue,
      },
      {
        'title': 'Book Appointment',
        'icon': Icons.calendar_month,
        'color': Colors.green,
      },
      {
        'title': 'Medical Records',
        'icon': Icons.folder_shared,
        'color': Colors.orange,
      },
      {
        'title': 'My Prescriptions',
        'icon': Icons.medication,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: items.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),

      itemBuilder: (context, index) {
        final item = items[index];

        final title =
            item['title'] as String;

        final color =
            item['color'] as Color;

        final icon =
            item['icon'] as IconData;

        return InkWell(
          borderRadius:
              BorderRadius.circular(18),

          onTap: () {
            if (title ==
                    'Find Doctor' ||
                title ==
                    'Book Appointment') {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const FindDoctorPage(),
                ),
              );
            } else if (title ==
                'Medical Records') {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const MedicalRecordsPage(),
                ),
              );
            } else if (title ==
                'My Prescriptions') {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const PrescriptionsPage(),
                ),
              );
            }
          },

          child: Container(
            padding:
                const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                          alpha: 0.04),

                  blurRadius: 10,

                  offset:
                      const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Container(
                  width: 60,
                  height: 60,

                  decoration:
                      BoxDecoration(
                    color: color.withValues(
                        alpha: 0.12),

                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  title,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF252B3A),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderWithAction(
    String title,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF1D2433),
          ),
        ),

        InkWell(
          onTap: onTap,

          child: Text(
            action,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF3F51B5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsList(
    List<Doctor> doctors,
  ) {
    return ListView.builder(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: doctors.length,

      itemBuilder:
          (context, index) {
        final doctor =
            doctors[index];

        return Container(
          margin:
              const EdgeInsets.only(
            bottom: 14,
          ),

          padding:
              const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                        alpha: 0.04),

                blurRadius: 10,

                offset:
                    const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              CircleAvatar(
                radius: 27,

                backgroundColor:
                    const Color(
                        0xFFE8EAF6),

                child: const Icon(
                  Icons.person,
                  color:
                      Color(0xFF3F51B5),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      doctor.name,

                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF252B3A),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      doctor.specialty,

                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,

      type:
          BottomNavigationBarType.fixed,

      selectedItemColor:
          const Color(0xFF3F51B5),

      unselectedItemColor:
          Colors.grey,

      backgroundColor:
          Colors.white,

      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            break;

          case 1:
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const FindDoctorPage(),
              ),
            );
            break;

          case 2:
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const MedicalRecordsPage(),
              ),
            );
            break;

          case 3:
            _showMessage(
              'Bills selected',
            );
            break;

          case 4:
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const ProfilePage(),
              ),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon:
              Icon(Icons.home_outlined),
          activeIcon:
              Icon(Icons.home),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_today_outlined,
          ),
          activeIcon: Icon(
            Icons.calendar_today,
          ),
          label: 'Appointments',
        ),

        BottomNavigationBarItem(
          icon:
              Icon(Icons.folder_outlined),
          activeIcon:
              Icon(Icons.folder),
          label: 'Records',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt_long_outlined,
          ),
          activeIcon: Icon(
            Icons.receipt_long,
          ),
          label: 'Bills',
        ),

        BottomNavigationBarItem(
          icon:
              Icon(Icons.person_outline),
          activeIcon:
              Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          duration:
              const Duration(seconds: 1),

          behavior:
              SnackBarBehavior.floating,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
  }
}