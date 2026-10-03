import 'package:flutter/material.dart';

class PrescriptionDetailPage extends StatelessWidget {
  final Map<String, dynamic> prescription;

  const PrescriptionDetailPage({
    super.key,
    required this.prescription,
  });

  String _doctorName() {
    final doctor = prescription['doctor_detail'];

    if (doctor is Map) {
      final user = doctor['user'];

      if (user is Map) {
        final first = user['first_name']?.toString() ?? '';
        final last = user['last_name']?.toString() ?? '';
        final name = '$first $last'.trim();

        if (name.isNotEmpty) return 'Dr. $name';

        return 'Dr. ${user['username'] ?? 'Doctor'}';
      }
    }

    return 'Doctor';
  }

  String _specialization() {
    final doctor = prescription['doctor_detail'];

    if (doctor is Map) {
      return doctor['specialization']?.toString() ??
          'Medical Specialist';
    }

    return 'Medical Specialist';
  }

  String _date() {
    final value = prescription['created_at'];

    if (value == null) return '';

    try {
      final date = DateTime.parse(value.toString());

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value.toString().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicine =
        prescription['medicine_name']?.toString() ?? 'Medicine';

    final dosage =
        prescription['dosage']?.toString() ?? '';

    final duration =
        prescription['duration']?.toString() ?? '';

    final instructions =
        prescription['instructions']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDoctorCard(),
                    const SizedBox(height: 12),
                    _buildConsultationSection(),
                    const SizedBox(height: 18),
                    const Text(
                      'Medicines',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF173B73),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMedicineCard(
                      medicine: medicine,
                      dosage: dosage,
                      duration: duration,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF173B73),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstructions(instructions),
                  ],
                ),
              ),
            ),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF173B73),
            ),
          ),
          const Expanded(
            child: Text(
              'Prescription',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173B73),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF173B73),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE1E9F2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE8F1FC),
            child: const Icon(
              Icons.person,
              color: Color(0xFF1976F3),
              size: 28,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29384A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _specialization(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF75879A),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Color(0xFF25B889),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Consulted',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF25A77C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _date(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8798A9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FC),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnosis / Consultation Notes',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF24476E),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Prescription issued after consultation. '
            'See Medical Records for detailed diagnosis and doctor notes.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: Color(0xFF7890A7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard({
    required String medicine,
    required String dosage,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFE0E8F1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF0),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.medication_outlined,
              size: 19,
              color: Color(0xFFE85B6B),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29384A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dosage,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6E8297),
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF637A91),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(String instructions) {
    final text = instructions.trim().isEmpty
        ? 'Take medicines as prescribed by your doctor.'
        : instructions;

    final points = text
        .split(RegExp(r'[.;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      children: points.map((point) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '•',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1976F3),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  point,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF71869C),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'PDF download will be connected next.',
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.download,
            size: 17,
          ),
          label: const Text(
            'Download PDF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976F3),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ),
    );
  }
}