import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import './LoginPage.dart';
import '../../doctor/doctor_find.dart';
import './medical_records.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'User';
  String username = '';
  String email = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getMe();

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];

      String fullName = [
        data['first_name'],
        data['last_name'],
      ]
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .join(' ');

      setState(() {
        name = fullName.isNotEmpty
            ? fullName
            : data['username']?.toString() ?? 'User';
        username = data['username']?.toString() ?? '';
        email = data['email']?.toString() ?? '';
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF173B67),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF173B67),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 24),

                    _sectionTitle('Personal Information'),
                    _sectionCard([
                      _infoRow('Name', name),
                      _infoRow(
                        'Username',
                        username.isEmpty ? 'Not added' : username,
                      ),
                      _infoRow(
                        'Email',
                        email.isEmpty ? 'Not added' : email,
                      ),
                      _infoRow('Mobile', 'Not added'),
                      _infoRow('Date of Birth', 'Not added'),
                      _infoRow('Gender', 'Not added'),
                    ]),

                    const SizedBox(height: 22),

                    _sectionTitle('Health Information'),
                    _sectionCard([
                      _infoRow('Blood Group', 'Not added'),
                      _infoRow('Allergies', 'Not added'),
                      _infoRow('Existing Conditions', 'Not added'),
                    ]),

                    const SizedBox(height: 22),

                    _sectionTitle('Insurance'),
                    _menuCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Add Insurance',
                      subtitle: 'Manage your insurance details',
                      onTap: () {
                        _showMessage('Insurance selected');
                      },
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('Documents'),
                    _menuCard(
                      icon: Icons.folder_outlined,
                      title: 'View Documents',
                      subtitle: 'Medical reports and documents',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicalRecordsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    _sectionTitle('Settings'),
                    _menuCard(
                      icon: Icons.lock_outline,
                      title: 'Privacy & Security',
                      subtitle: 'Password and account security',
                      onTap: () {
                        _showMessage('Privacy & Security selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuCard(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        _showMessage('Notifications selected');
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 21),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Color(0xFFFFCDD2),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2EAF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF2E6FA3),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF173B67),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  username.isEmpty ? 'Patient' : '@$username',
                  style: const TextStyle(
                    color: Color(0xFF7890A8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _showMessage('Edit Profile selected');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E6FA3),
                    side: const BorderSide(
                      color: Color(0xFFB9D2E8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF173B67),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE0E8F1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEAF0F6),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7890A8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF173B67),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFE0E8F1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E6FA3),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF173B67),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7890A8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8AA0B5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E6FA3),
      unselectedItemColor: const Color(0xFF8AA0B5),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pop(context);
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FindDoctorPage(),
              ),
            );
            break;

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MedicalRecordsPage(),
              ),
            );
            break;

          case 3:
            _showMessage('Bills selected');
            break;

          case 4:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Bills',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}