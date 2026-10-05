import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'medical_records_scan.dart';


class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() =>
      _MedicalRecordsPageState();
}

class _MedicalRecordsPageState
    extends State<MedicalRecordsPage> {
  final ApiService _apiService = ApiService();

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  List<Map<String, dynamic>> records = [];
  bool isLoading = true;
  String? errorMessage;

  final List<String> filters = [
    'All',
    'Reports',
    'Prescriptions',
    'Visits',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.fetchMedicalRecords();

      if (!mounted) return;

      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    final search =
        searchController.text.toLowerCase().trim();

    return records.where((record) {
      final diagnosis =
          record['diagnosis']?.toString().toLowerCase() ?? '';

      final notes =
          record['doctor_notes']?.toString().toLowerCase() ?? '';

      final doctor =
          _doctorName(record).toLowerCase();

      final matchesSearch =
          search.isEmpty ||
          diagnosis.contains(search) ||
          notes.contains(search) ||
          doctor.contains(search);

      // Medical-record API currently represents reports.
      // Prescriptions will be connected separately later.
      final matchesFilter =
          selectedFilter == 'All' ||
          selectedFilter == 'Reports';

      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _doctorName(Map<String, dynamic> record) {
    final doctor = record['doctor_detail'];

    if (doctor is Map<String, dynamic>) {
      final user = doctor['user'];

      if (user is Map<String, dynamic>) {
        final first =
            user['first_name']?.toString() ?? '';

        final last =
            user['last_name']?.toString() ?? '';

        final full =
            '$first $last'.trim();

        if (full.isNotEmpty) {
          return 'Dr. $full';
        }

        final username =
            user['username']?.toString() ?? '';

        if (username.isNotEmpty) {
          return 'Dr. $username';
        }
      }
    }

    return 'Doctor';
  }

  String _specialization(
      Map<String, dynamic> record) {
    final doctor = record['doctor_detail'];

    if (doctor is Map<String, dynamic>) {
      return doctor['specialization']?.toString() ??
          'Medical Specialist';
    }

    return 'Medical Specialist';
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    final raw = value.toString();

    try {
      final date = DateTime.parse(raw);

      return '${date.day.toString().padLeft(2, '0')} '
          '${_month(date.month)} '
          '${date.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  String _month(int month) {
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
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFD),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF123E68),
          ),
        ),
        title: const Text(
          'Medical Records',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF123E68),
          ),
        ),
      ),

      body: Column(
        children: [
          // SEARCH
       // SEARCH
Padding(
  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
  child: TextField(
    controller: searchController,
    onChanged: (_) {
      setState(() {});
    },
    decoration: InputDecoration(
      hintText: 'Search records...',
      // keep all your existing TextField code
    ),
  ),
),

// ADD THIS
Padding(
  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MedicalRecordPage(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD1E7F8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: Color(0xFF2589E8),
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Medical Record',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Capture or upload a medical report',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6685A0),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 13,
            color: Color(0xFF2589E8),
          ),
        ],
      ),
    ),
  ),
),

// FILTERS

          // FILTERS
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final selected =
                    selectedFilter == filter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(
                      right: 8,
                      bottom: 8,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2589E8)
                          : const Color(0xFFF0F5F9),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(
                                0xFF6685A0,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // RECORDS
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2589E8),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 45,
                color: Color(0xFF2589E8),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load records',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF123E68),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6685A0),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2589E8),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = filteredRecords;

    if (data.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF2589E8),
        onRefresh: _loadRecords,
        child: ListView(
          children: const [
            SizedBox(height: 130),
            Icon(
              Icons.folder_open_outlined,
              size: 55,
              color: Color(0xFFB7CBD9),
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                'No medical records found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF456174),
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Your medical reports will appear here.',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8A9BAB),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2589E8),
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          5,
          16,
          25,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _recordCard(data[index]);
        },
      ),
    );
  }

  Widget _recordCard(
      Map<String, dynamic> record) {
    final diagnosis =
        record['diagnosis']?.toString() ??
            'Medical Report';

    final notes =
        record['doctor_notes']?.toString() ??
            '';

    final doctor = _doctorName(record);

    final specialty =
        _specialization(record);

    final date =
        _formatDate(record['created_at']);

    return GestureDetector(
      onTap: () {
        _showDetails(record);
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xFFDCE8F2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3FF),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF2589E8),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnosis,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF123E68),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    doctor,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w600,
                      color: Color(0xFF456174),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF8A9BAB),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 11,
                        color: Color(0xFF2589E8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 8,
                          color:
                              Color(0xFF8A9BAB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFF9AAEBD),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(
      Map<String, dynamic> record) {
    final diagnosis =
        record['diagnosis']?.toString() ??
            'Medical Report';

    final notes =
        record['doctor_notes']?.toString() ??
            'No doctor notes available.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            18,
            15,
            18,
            25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFDCE8F2),
                      borderRadius:
                          BorderRadius.circular(5),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Medical Record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),

                const SizedBox(height: 15),

                _detailRow(
                  Icons.medical_information_outlined,
                  'Diagnosis',
                  diagnosis,
                ),

                _detailRow(
                  Icons.person_outline,
                  'Doctor',
                  _doctorName(record),
                ),

                _detailRow(
                  Icons.local_hospital_outlined,
                  'Specialization',
                  _specialization(record),
                ),

                _detailRow(
                  Icons.calendar_today_outlined,
                  'Date',
                  _formatDate(
                    record['created_at'],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Doctor Notes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF5FAFD),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xFF6685A0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF2589E8),
          ),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A9BAB),
            ),
          ),
          Expanded(
            child: Text(
              value,
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