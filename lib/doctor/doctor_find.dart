import 'package:flutter/material.dart';
import '../pages/services/api_service.dart';
import '../models.dart';
import 'doctor_profile.dart';

class FindDoctorPage extends StatefulWidget {
  const FindDoctorPage({super.key});

  @override
  State<FindDoctorPage> createState() => _FindDoctorPageState();
}

class _FindDoctorPageState extends State<FindDoctorPage> {
  final ApiService _apiService = ApiService();

  final TextEditingController _searchController =
      TextEditingController();

  late Future<List<Doctor>> _doctorsFuture;

  String? selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() {
    _doctorsFuture = _apiService.fetchDoctor(
      search: null,
      specialty: selectedSpecialty,
    );
  }

  void _search(String value) {
    setState(() {
      _doctorsFuture = _apiService.fetchDoctor(
        search: value.trim().isEmpty ? null : value.trim(),
        specialty: selectedSpecialty,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            _filters(),
            const SizedBox(height: 10),
            Expanded(
              child: _doctorList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            'Find a Doctor',
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

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xFFDCE8F2),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _search,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF71899B),
            ),
            hintText: 'Search by doctor or specialty',
            hintStyle: TextStyle(
              fontSize: 12,
              color: Color(0xFF9AAEBD),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        children: [
          _filterChip(
            selectedSpecialty ?? 'Specialty',
            _showSpecialty,
          ),
          _filterChip('Availability', () {}),
          _filterChip('Gender', () {}),
          _filterChip('Experience', () {}),
          _filterChip('Consultation Fee', () {}),
        ],
      ),
    );
  }

  Widget _filterChip(
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD6E8F5),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF47708F),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 13,
              color: Color(0xFF2589E8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorList() {
    return FutureBuilder<List<Doctor>>(
      future: _doctorsFuture,
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
          return const Center(
            child: Text('Unable to load doctors'),
          );
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return const Center(
            child: Text('No doctors found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            5,
            16,
            20,
          ),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return _doctorCard(doctors[index]);
          },
        );
      },
    );
  }

  Widget _doctorCard(Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorProfilePage(
              doctor: doctor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFDCE8F2),
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/doctor1.png',
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF123E68),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6685A0),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${doctor.experience} years experience',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6685A0),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    doctor.availableDays,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6685A0),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${doctor.consultationFee}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),

                const SizedBox(height: 12),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: Color(0xFF2589E8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSpecialty() {
    final specialties = [
      'All',
      'Cardiology',
      'General Medicine',
      'Neurology',
      'Dermatology',
      'Pediatrics',
      'Dentistry',
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: specialties.map((specialty) {
            return ListTile(
              title: Text(specialty),
              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedSpecialty =
                      specialty == 'All'
                          ? null
                          : specialty;

                  _loadDoctors();
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}