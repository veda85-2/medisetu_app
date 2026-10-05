import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'appointment_details.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() =>
      _MyAppointmentsPageState();
}

class _MyAppointmentsPageState
    extends State<MyAppointmentsPage> {
  final ApiService _apiService = ApiService();

  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    _appointmentsFuture =
        _apiService.fetchAppointments();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadAppointments();
    });

    await _appointmentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF123E68),
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2589E8),
              ),
            );
          }

          if (snapshot.hasError) {
            return _errorView();
          }

          final appointments =
              snapshot.data ?? [];

          if (appointments.isEmpty) {
            return _emptyView();
          }

          return RefreshIndicator(
            color: const Color(0xFF2589E8),
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _appointmentCard(
                  appointments[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _appointmentCard(
    Map<String, dynamic> appointment,
  ) {
    final doctor =
        appointment['doctor_detail'];

    String doctorName = 'Doctor';
    String specialty = 'General Physician';

    if (doctor is Map) {
      final firstName =
          doctor['first_name']?.toString() ?? '';

      final lastName =
          doctor['last_name']?.toString() ?? '';

      final fullName =
          '$firstName $lastName'.trim();

      if (fullName.isNotEmpty) {
        doctorName = fullName;
      }

      specialty =
          doctor['specialization']?.toString() ??
              doctor['specialty']?.toString() ??
              specialty;
    }

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
            ?.toString() ??
            'PENDING';

    final reason =
        appointment['reason']
            ?.toString() ??
            'Consultation';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE7F3FF),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF2589E8),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. $doctorName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF123E68),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 10,
                        color:
                            Color(0xFF6685A0),
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _infoItem(
                Icons.calendar_today_outlined,
                date,
              ),

              const SizedBox(width: 18),

              _infoItem(
                Icons.access_time_outlined,
                time,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: Color(0xFF2589E8),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 10,
                    color:
                        Color(0xFF6685A0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppointmentDetailsPage(
                      appointment:
                          appointment,
                    ),
                  ),
                );
              },
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF2589E8),
                side: const BorderSide(
                  color: Color(0xFF2589E8),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View Appointment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF2589E8),
        ),
        const SizedBox(width: 6),
        Text(
          value.isEmpty ? 'Not available' : value,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF456174),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final normalized =
        status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: normalized == 'CANCELLED'
            ? const Color(0xFFFFE8E8)
            : const Color(0xFFE2F7EC),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: normalized == 'CANCELLED'
              ? const Color(0xFFD64545)
              : const Color(0xFF28A76A),
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE7F3FF),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 40,
                color: Color(0xFF2589E8),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Appointments Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Your booked appointments will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6685A0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Color(0xFFD64545),
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load appointments',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadAppointments();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}