import 'package:flutter/material.dart';
import '../models.dart';
import '../pages/appointment/book_appointment.dart';

class DoctorProfilePage extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfilePage({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),

      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _doctorHeader(),
                    const SizedBox(height: 12),

                    _infoCard(
                      'About',
                      doctor.qualification,
                    ),

                    _infoCard(
                      'Specialization',
                      doctor.specialty,
                    ),

                    _infoCard(
                      'Experience',
                      '${doctor.experience} years',
                    ),

                    _infoCard(
                      'Available Days',
                      doctor.availableDays,
                    ),

                    _infoCard(
                      'Available Time',
                      '${_formatTime(doctor.availableFrom)} - '
                          '${_formatTime(doctor.availableTo)}',
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookAppointmentPage(
                                doctor: doctor,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2589E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF123E68),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Doctor Profile',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123E68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/doctor1.png',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123E68),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            doctor.specialty,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6685A0),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '₹${doctor.consultationFee} consultation',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2589E8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123E68),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? 'Not available' : value,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6685A0),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String value) {
    if (value.isEmpty) return '--';

    final parts = value.split(':');

    if (parts.length < 2) return value;

    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? 'PM' : 'AM';

    hour %= 12;

    if (hour == 0) hour = 12;

    return '$hour:$minute $period';
  }
}