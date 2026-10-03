import 'package:flutter/material.dart';
import '../../models.dart';

class AppointmentConfirmedPage extends StatelessWidget {
  final Doctor doctor;
  final DateTime date;
  final TimeOfDay time;
  final String consultationType;

  const AppointmentConfirmedPage({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    required this.consultationType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 35),

              // SUCCESS ICON
              Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE2F7EC),
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Color(0xFF28A76A),
                ),
              ),

              const SizedBox(height: 16),

              // TITLE
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF123E68),
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Your appointment has been successfully scheduled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6685A0),
                ),
              ),

              const SizedBox(height: 25),

              // DETAILS
              _detailsCard(context),

              const SizedBox(height: 16),

              // NOTIFICATION
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Color(0xFF2589E8),
                    ),

                    SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        'You will receive a reminder before your appointment.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF456174),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // VIEW APPOINTMENT
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2589E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'View Appointment',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ADD TO CALENDAR
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Calendar integration will be added next.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Add to Calendar',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget _detailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        children: [
          // DOCTOR IMAGE
          ClipOval(
            child: Image.asset(
              'assets/doctor1.png',
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE7F3FF),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color: Color(0xFF2589E8),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // DOCTOR NAME
          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123E68),
            ),
          ),

          const SizedBox(height: 3),

          // SPECIALTY
          Text(
            doctor.specialty,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6685A0),
            ),
          ),

          const SizedBox(height: 18),

          // DATE
          _row(
            Icons.calendar_today,
            'Date',
            '${date.day}/${date.month}/${date.year}',
          ),

          // TIME
          _row(
            Icons.access_time,
            'Time',
            time.format(context),
          ),

          // CONSULTATION
          _row(
            Icons.medical_services_outlined,
            'Consultation',
            consultationType,
          ),

          // FEE
          _row(
            Icons.currency_rupee,
            'Fee',
            '₹${doctor.consultationFee}',
          ),

          // APPOINTMENT ID
          _row(
            Icons.confirmation_number_outlined,
            'Appointment ID',
            _appointmentId(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPOINTMENT ID
  // ============================================================

  String _appointmentId() {
    final timestamp =
        date.millisecondsSinceEpoch.toString();

    final shortId = timestamp.length > 7
        ? timestamp.substring(7)
        : timestamp;

    return 'MED-${doctor.id}-$shortId';
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _row(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF2589E8),
          ),

          const SizedBox(width: 9),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8A9BAB),
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF456174),
              ),
            ),
          ),
        ],
      ),
    );
  }
}