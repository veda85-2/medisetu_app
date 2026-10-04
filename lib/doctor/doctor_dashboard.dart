import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  final ApiService _apiService = ApiService();

  String doctorName = 'Doctor';
  bool loading = true;
  String? error;

  int totalPatients = 0;
  int totalAppointments = 0;
  int upcomingAppointments = 0;
  int completedAppointments = 0;

  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final userResult = await AuthService.getMe();
      final dashboard =
          await _apiService.fetchDoctorDashboard();

      if (!mounted) return;

      final user = userResult['data'] ?? {};

      setState(() {
        final firstName =
            user['first_name']?.toString() ?? '';

        final username =
            user['username']?.toString() ?? '';

        doctorName = firstName.isNotEmpty
            ? firstName
            : username.isNotEmpty
                ? username
                : 'Doctor';

        totalPatients =
            dashboard['total_patients'] ?? 0;

        totalAppointments =
            dashboard['total_appointments'] ?? 0;

        upcomingAppointments =
            dashboard['upcoming_appointments'] ?? 0;

        completedAppointments =
            dashboard['completed_appointments'] ?? 0;

        appointments =
            dashboard['recent_appointments'] ?? [];

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: loadDashboard,
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
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

                          _buildOverview(),

                          const SizedBox(height: 28),

                          const Text(
                            'What do you need today?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2433),
                            ),
                          ),

                          const SizedBox(height: 15),

                          _buildActionGrid(),

                          const SizedBox(height: 28),

                          _buildAppointmentHeader(),

                          const SizedBox(height: 15),

                          _buildAppointments(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor:
              const Color(0xFF3F51B5),
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
                      'Welcome, Dr. $doctorName',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2433),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              const Text(
                'Manage your patients today',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none,
            size: 23,
            color: Color(0xFF252B3A),
          ),
        ),
      ],
    );
  }

  // OVERVIEW

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2433),
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _statCard(
                'Patients',
                totalPatients,
                Icons.people_outline,
                const Color(0xFFE3F2FD),
                Colors.blue,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                'Appointments',
                totalAppointments,
                Icons.calendar_month,
                const Color(0xFFE8F5E9),
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _statCard(
                'Upcoming',
                upcomingAppointments,
                Icons.event_available,
                const Color(0xFFFFF3E0),
                Colors.orange,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                'Completed',
                completedAppointments,
                Icons.check_circle_outline,
                const Color(0xFFF3E5F5),
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    int value,
    IconData icon,
    Color background,
    Color iconColor,
  ) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252B3A),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ACTION GRID

  Widget _buildActionGrid() {
    final actions = [
      {
        'title': 'Appointments',
        'icon': Icons.calendar_month,
        'color': Colors.blue,
      },
      {
        'title': 'My Patients',
        'icon': Icons.people,
        'color': Colors.green,
      },
      {
        'title': 'Prescriptions',
        'icon': Icons.medication,
        'color': Colors.purple,
      },
      {
        'title': 'My Profile',
        'icon': Icons.person,
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];

        return InkWell(
          borderRadius:
              BorderRadius.circular(18),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  '${item['title']} selected',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: (item['color']
                            as Color)
                        .withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color:
                        item['color'] as Color,
                    size: 27,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF252B3A),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // APPOINTMENTS

  Widget _buildAppointmentHeader() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2433),
          ),
        ),

        Text(
          '$upcomingAppointments',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F51B5),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointments() {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 42,
              color: Colors.grey,
            ),

            SizedBox(height: 10),

            Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: appointments
          .take(5)
          .map((appointment) {
        final patient =
            appointment['patient'] ?? {};

        final user =
            patient['user'] ?? {};

        final firstName =
            user['first_name']?.toString() ?? '';

        final lastName =
            user['last_name']?.toString() ?? '';

        final name =
            '$firstName $lastName'.trim();

        final patientName =
            name.isEmpty ? 'Patient' : name;

        final date =
            appointment['appointment_date']
                    ?.toString() ??
                '';

        final time =
            appointment['appointment_time']
                    ?.toString() ??
                '';

        final reason =
            appointment['reason']
                    ?.toString() ??
                'Consultation';

        return Container(
          margin:
              const EdgeInsets.only(bottom: 12),
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8EAF6),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF3F51B5),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      reason,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$date  •  $time',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ERROR

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                  error = null;
                });

                loadDashboard();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor:
          const Color(0xFF3F51B5),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              index == 1
                  ? 'Appointments'
                  : index == 2
                      ? 'Patients'
                      : index == 3
                          ? 'Prescriptions'
                          : 'Profile',
            ),
          ),
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_today_outlined,
          ),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.medication_outlined,
          ),
          label: 'Prescriptions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}