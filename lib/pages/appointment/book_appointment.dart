import 'package:flutter/material.dart';
import '../../models.dart';
import './appointment_confirmed.dart';

class BookAppointmentPage extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentPage({
    super.key,
    required this.doctor,
  });

  @override
  State<BookAppointmentPage> createState() =>
      _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  String consultationType = 'In-person';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _progress(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _doctorCard(),

                    const SizedBox(height: 20),

                    _title('Select Date'),
                    const SizedBox(height: 10),
                    _dates(),

                    const SizedBox(height: 20),

                    _title('Select Time'),
                    const SizedBox(height: 10),
                    _times(),

                    const SizedBox(height: 20),

                    _title('Consultation Type'),
                    const SizedBox(height: 10),
                    _consultationTypes(),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2589E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF1D2433),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2433),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 15,
      ),
      child: Row(
        children: [
          _step(
            number: '1',
            title: 'Doctor',
            active: true,
          ),

          Expanded(
            child: Container(
              height: 2,
              color: const Color(0xFF2589E8),
            ),
          ),

          _step(
            number: '2',
            title: 'Schedule',
            active: true,
          ),

          Expanded(
            child: Container(
              height: 2,
              color: const Color(0xFFCBD5E1),
            ),
          ),

          _step(
            number: '3',
            title: 'Confirm',
            active: false,
          ),
        ],
      ),
    );
  }

  Widget _step({
    required String number,
    required String title,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF2589E8)
                : const Color(0xFFE2E8F0),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active
                ? const Color(0xFF2589E8)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // DOCTOR CARD
  // ------------------------------------------------------------

  Widget _doctorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/doctor1.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 38,
                    color: Color(0xFF2589E8),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2433),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.doctor.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),

                    const SizedBox(width: 3),

                    Text(
                      widget.doctor.rating > 0
                          ? widget.doctor.rating.toStringAsFixed(1)
                          : 'New',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (widget.doctor.experience > 0) ...[
                      const SizedBox(width: 10),
                      Text(
                        '${widget.doctor.experience} yrs exp.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          Text(
            '₹${widget.doctor.consultationFee}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2589E8),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------

  Widget _title(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D2433),
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE SELECTOR
  // ------------------------------------------------------------

  Widget _dates() {
    final today = DateTime.now();

    return SizedBox(
      height: 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime(
            today.year,
            today.month,
            today.day + index,
          );

          final selected =
              selectedDate.year == date.year &&
              selectedDate.month == date.month &&
              selectedDate.day == date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedTime = null;
              });
            },
            child: Container(
              width: 62,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2589E8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2589E8)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF1D2433),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayName(int weekday) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[weekday - 1];
  }

  // ------------------------------------------------------------
  // TIME SLOTS
  // ------------------------------------------------------------

  Widget _times() {
    final from = _parse(widget.doctor.availableFrom);
    final to = _parse(widget.doctor.availableTo);

    final List<TimeOfDay> slots = [];

    if (from != null && to != null) {
      int current = from.hour * 60 + from.minute;
      final end = to.hour * 60 + to.minute;

      while (current < end) {
        slots.add(
          TimeOfDay(
            hour: current ~/ 60,
            minute: current % 60,
          ),
        );

        current += 60;
      }
    }

    // Fallback so the UI never becomes empty
    if (slots.isEmpty) {
      slots.addAll([
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 16, minute: 0),
      ]);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((time) {
        final selected =
            selectedTime?.hour == time.hour &&
            selectedTime?.minute == time.minute;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = time;
            });
          },
          child: Container(
            width: 82,
            padding: const EdgeInsets.symmetric(
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF2589E8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2589E8)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Text(
                time.format(context),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF334155),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  TimeOfDay? _parse(String value) {
    if (value.isEmpty) return null;

    final parts = value.split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  // ------------------------------------------------------------
  // CONSULTATION TYPE
  // ------------------------------------------------------------

  Widget _consultationTypes() {
    return Row(
      children: [
        Expanded(
          child: _consultationCard(
            title: 'In-person',
            icon: Icons.local_hospital_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _consultationCard(
            title: 'Video',
            icon: Icons.videocam_outlined,
          ),
        ),
      ],
    );
  }

  Widget _consultationCard({
    required String title,
    required IconData icon,
  }) {
    final selected =
        consultationType == title ||
        (title == 'Video' &&
            consultationType == 'Video Consultation');

    return GestureDetector(
      onTap: () {
        setState(() {
          consultationType =
              title == 'Video'
                  ? 'Video Consultation'
                  : 'In-person';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF5FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF2589E8)
                : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? const Color(0xFF2589E8)
                  : const Color(0xFF64748B),
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFF2589E8)
                    : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTINUE
  // ------------------------------------------------------------

  void _continue() {
    // Prevent null error
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a time slot',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AppointmentConfirmedPage(
            doctor: widget.doctor,
            date: selectedDate,
            time: selectedTime!,
            consultationType: consultationType,
          );
        },
      ),
    );
  }
}