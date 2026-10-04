import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'prescriptions_detail.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;
  String? errorMessage;

  int selectedTab = 0;

  final tabs = ['Active', 'Completed', 'All'];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.fetchPrescriptions();

      if (!mounted) return;

      setState(() {
        prescriptions = data;
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

  List<Map<String, dynamic>> get filteredPrescriptions {
    if (selectedTab == 2) {
      return prescriptions;
    }

    return prescriptions.where((item) {
      final status = item['status']?.toString().toLowerCase();

      if (selectedTab == 0) {
        return status == null || status == 'active';
      }

      return status == 'completed';
    }).toList();
  }

  String _doctorName(Map<String, dynamic> prescription) {
    final doctor = prescription['doctor_detail'];

    if (doctor is Map) {
      final user = doctor['user'];

      if (user is Map) {
        final first = user['first_name']?.toString() ?? '';
        final last = user['last_name']?.toString() ?? '';

        final name = '$first $last'.trim();

        if (name.isNotEmpty) {
          return 'Dr. $name';
        }

        final username = user['username']?.toString();

        if (username != null && username.isNotEmpty) {
          return 'Dr. $username';
        }
      }
    }

    return 'Doctor';
  }

  String _specialization(Map<String, dynamic> prescription) {
    final doctor = prescription['doctor_detail'];

    if (doctor is Map) {
      return doctor['specialization']?.toString() ??
          'Medical Specialist';
    }

    return 'Medical Specialist';
  }

  String _formatDate(dynamic value) {
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

  bool _isCompleted(Map<String, dynamic> item) {
    return item['status']?.toString().toLowerCase() == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1976F3),
                      ),
                    )
                  : errorMessage != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final selected = selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1976F3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          selected ? Colors.white : const Color(0xFF7890AA),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    final items = filteredPrescriptions;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPrescriptions,
        child: ListView(
          children: const [
            SizedBox(height: 150),
            Icon(
              Icons.medication_outlined,
              size: 60,
              color: Color(0xFFB7C7D9),
            ),
            SizedBox(height: 14),
            Center(
              child: Text(
                'No prescriptions found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF53657A),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrescriptions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          ...items.map(_buildPrescriptionCard),
          const SizedBox(height: 8),
          _buildRefillCard(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(
    Map<String, dynamic> prescription,
  ) {
    final completed = _isCompleted(prescription);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE3EAF2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F1FC),
            child: const Icon(
              Icons.person,
              color: Color(0xFF1976F3),
              size: 24,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(prescription['created_at']),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8496A9),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _doctorName(prescription),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29384A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _specialization(prescription),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8292A4),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFE8EEF5)
                      : const Color(0xFFE1F8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  completed ? 'Completed' : 'Active',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: completed
                        ? const Color(0xFF65788D)
                        : const Color(0xFF20A77A),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrescriptionDetailPage(
                        prescription: prescription,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976F3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefillCard() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication,
              color: Color(0xFF1976F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a refill?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29384A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Request medicine refill with just a click.',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF75899F),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 13,
            color: Color(0xFF1976F3),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load prescriptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadPrescriptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}