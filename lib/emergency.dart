import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _nearbyHospitals() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/hospitals+near+me',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF123B6D),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency / Quick Help',
          style: TextStyle(
            color: Color(0xFF123B6D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.shield_outlined,
              color: Colors.blue,
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
        child: Column(
          children: [
            _emergencyBanner(),
            const SizedBox(height: 12),
            _emergencyCard(
              icon: Icons.local_shipping_outlined,
              title: 'Ambulance',
              subtitle: 'Request emergency transport',
              buttonText: 'Call Now',
              color: const Color(0xFFFF2438),
              onTap: () => _call('102'),
            ),
            const SizedBox(height: 10),
            _emergencyCard(
              icon: Icons.local_hospital_outlined,
              title: 'Hospital Emergency',
              subtitle: 'Contact hospital emergency',
              buttonText: 'Call Now',
              color: const Color(0xFF1976E8),
              onTap: () => _call('+911204567890'),
            ),
            const SizedBox(height: 10),
            _nearbyCard(),
            const SizedBox(height: 14),
            _contactsCard(),
          ],
        ),
      ),
    );
  }

  Widget _emergencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFF2438),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need immediate assistance?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Get help, call emergency services or find nearby hospitals.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emergencyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF173B67),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7890A8),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.phone,
                size: 13,
              ),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbyCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2438)
                      .withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFFF2438),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Nearby Hospital',
                    style: TextStyle(
                      color: Color(0xFF173B67),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Locate nearby hospitals & clinics',
                    style: TextStyle(
                      color: Color(0xFF7890A8),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: _nearbyHospitals,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F2FD),
                foregroundColor: const Color(0xFF1976E8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'View Nearby',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.phone,
                color: Color(0xFF1976E8),
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  color: Color(0xFF173B67),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFFD5E5F5),
          ),
          _contactRow(
            Icons.local_hospital_outlined,
            'Hospital Emergency',
            '+91 120 456 7890',
            '+911204567890',
          ),
          _contactRow(
            Icons.local_shipping_outlined,
            'Ambulance',
            '102',
            '102',
          ),
          _contactRow(
            Icons.shield_outlined,
            'Police',
            '100',
            '100',
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    IconData icon,
    String title,
    String number,
    String callNumber,
  ) {
    return InkWell(
      onTap: () => _call(callNumber),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1976E8),
              size: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4E6680),
                  fontSize: 9,
                ),
              ),
            ),
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFF173B67),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}