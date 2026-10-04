import 'package:flutter/material.dart';
import '../../models.dart';
import 'appointment_details.dart';

class AppointmentConfirmedPage
    extends StatelessWidget {
  final Doctor doctor;
  final DateTime date;
  final TimeOfDay time;
  final String consultationType;
  final Map<String, dynamic> appointment;

  const AppointmentConfirmedPage({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    required this.consultationType,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAFD),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 35),

              Container(
                width: 75,
                height: 75,
                decoration:
                    const BoxDecoration(
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

              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w700,
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

              _detailsCard(context),

              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFE7F3FF),
                  borderRadius:
                      BorderRadius.circular(11),
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
                          color:
                              Color(0xFF456174),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
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
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2589E8),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'View Appointment',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
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

  Widget _detailsCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/doctor1.png',
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  width: 65,
                  height: 65,
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Color(0xFFE7F3FF),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color:
                        Color(0xFF2589E8),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF123E68),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            doctor.specialty,
            style: const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF6685A0),
            ),
          ),

          const SizedBox(height: 18),

          _row(
            Icons.calendar_today,
            'Date',
            '${date.day}/${date.month}/${date.year}',
          ),

          _row(
            Icons.access_time,
            'Time',
            time.format(context),
          ),

          _row(
            Icons.medical_services_outlined,
            'Consultation',
            consultationType,
          ),

          _row(
            Icons.currency_rupee,
            'Fee',
            '₹${doctor.consultationFee}',
          ),

          _row(
            Icons.confirmation_number_outlined,
            'Appointment ID',
            _appointmentId(),
          ),
        ],
      ),
    );
  }

  String _appointmentId() {
    final id =
        appointment['id'];

    if (id != null) {
      return 'MED-$id';
    }

    return 'MED-PENDING';
  }

  Widget _row(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color:
                const Color(0xFF2589E8),
          ),

          const SizedBox(width: 9),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF8A9BAB),
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF456174),
              ),
            ),
          ),
        ],
      ),
    );
  }
}