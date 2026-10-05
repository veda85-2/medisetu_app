import 'package:flutter/material.dart';
import 'package:medisetu/pages/appointment/my_appointments.dart';

import '../../models.dart';
import '../../services/api_service.dart';
import 'appointment_confirmed.dart';
import 'my_appointments.dart';

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

class _BookAppointmentPageState
    extends State<BookAppointmentPage> {
  final ApiService _apiService = ApiService();

  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  String consultationType = 'In-person';

  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    _setFirstAvailableDate();
  }

  void _setFirstAvailableDate() {
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (_isDoctorAvailableOn(date)) {
        selectedDate = date;
        return;
      }
    }

    selectedDate = today;
  }

  bool _isDoctorAvailableOn(DateTime date) {
    final availableDays =
        widget.doctor.availableDays.toLowerCase();

    if (availableDays.isEmpty) {
      return true;
    }

    final dayName =
        _dayName(date.weekday).toLowerCase();

    return availableDays.contains(dayName);
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  List<DateTime> _getAvailableDates() {
    final dates = <DateTime>[];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (_isDoctorAvailableOn(date)) {
        dates.add(date);
      }
    }

    return dates;
  }

  List<TimeOfDay> _getTimeSlots() {
    int startHour = 9;
    int startMinute = 0;
    int endHour = 17;
    int endMinute = 0;

    try {
      final from = widget.doctor.availableFrom;

      if (from.isNotEmpty) {
        final parts = from.split(':');

        if (parts.length >= 2) {
          startHour = int.parse(parts[0]);
          startMinute = int.parse(parts[1]);
        }
      }
    } catch (_) {}

    try {
      final to = widget.doctor.availableTo;

      if (to.isNotEmpty) {
        final parts = to.split(':');

        if (parts.length >= 2) {
          endHour = int.parse(parts[0]);
          endMinute = int.parse(parts[1]);
        }
      }
    } catch (_) {}

    final slots = <TimeOfDay>[];

    int currentMinutes =
        startHour * 60 + startMinute;

    final endingMinutes =
        endHour * 60 + endMinute;

    while (currentMinutes < endingMinutes) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;

      slots.add(
        TimeOfDay(
          hour: hour,
          minute: minute,
        ),
      );

      currentMinutes += 30;
    }

    return slots;
  }

  Future<void> _continue() async {
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

    if (isBooking) return;

    setState(() {
      isBooking = true;
    });

    try {
      final appointment =
          await _apiService.createAppointment(
        doctorId:
            int.parse(widget.doctor.id.toString()),
        date: selectedDate,
        time:
            '${selectedTime!.hour.toString().padLeft(2, '0')}:'
            '${selectedTime!.minute.toString().padLeft(2, '0')}:00',
        reason: 'Consultation',
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppointmentConfirmedPage(
            doctor: widget.doctor,
            date: selectedDate,
            time: selectedTime!,
            consultationType:
                consultationType,
            appointment: appointment,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to book appointment: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getAvailableDates();
    final timeSlots = _getTimeSlots();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAFD),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF123E68),
        elevation: 0,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _doctorCard(),

            const SizedBox(height: 24),

            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 90,

              child: ListView.separated(
                scrollDirection:
                    Axis.horizontal,

                itemCount: dates.length,

                separatorBuilder:
                    (_, __) =>
                        const SizedBox(width: 10),

                itemBuilder:
                    (context, index) {
                  final date = dates[index];

                  final isSelected =
                      date.year ==
                              selectedDate.year &&
                          date.month ==
                              selectedDate.month &&
                          date.day ==
                              selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                        selectedTime = null;
                      });
                    },

                    child: Container(
                      width: 70,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 10,
                      ),

                      decoration:
                          BoxDecoration(
                        color: isSelected
                            ? const Color(
                                0xFF2589E8,
                              )
                            : Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),

                        border: Border.all(
                          color: isSelected
                              ? const Color(
                                  0xFF2589E8,
                                )
                              : const Color(
                                  0xFFDCE8F2,
                                ),
                        ),
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            _shortDay(
                              date.weekday,
                            ),

                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,

                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF6685A0,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${date.day}',

                            style: TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,

                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF123E68,
                                    ),
                            ),
                          ),

                          Text(
                            _shortMonth(
                              date.month,
                            ),

                            style: TextStyle(
                              fontSize: 11,

                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF6685A0,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount: timeSlots.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),

              itemBuilder:
                  (context, index) {
                final time = timeSlots[index];

                final isSelected =
                    selectedTime?.hour ==
                            time.hour &&
                        selectedTime?.minute ==
                            time.minute;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                  },

                  child: Container(
                    alignment:
                        Alignment.center,

                    decoration:
                        BoxDecoration(
                      color: isSelected
                          ? const Color(
                              0xFF2589E8,
                            )
                          : Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),

                      border: Border.all(
                        color: isSelected
                            ? const Color(
                                0xFF2589E8,
                              )
                            : const Color(
                                0xFFDCE8F2,
                              ),
                      ),
                    ),

                    child: Text(
                      time.format(context),

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,

                        color: isSelected
                            ? Colors.white
                            : const Color(
                                0xFF456174,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'Consultation Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child:
                      _consultationOption(
                    title: 'In-person',
                    icon:
                        Icons
                            .local_hospital_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                      _consultationOption(
                    title: 'Video',
                    icon:
                        Icons
                            .videocam_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color:
                      const Color(0xFFDCE8F2),
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    color:
                        Color(0xFF2589E8),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Color(0xFF6685A0),
                      ),
                    ),
                  ),

                  Text(
                    '₹${widget.doctor.consultationFee}',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF123E68),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CONTINUE / BOOK APPOINTMENT
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed:
                    isBooking
                        ? null
                        : _continue,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2589E8,
                  ),

                  disabledBackgroundColor:
                      const Color(
                    0xFFB8CBD9,
                  ),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                child: isBooking
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // ==================================================
            // VIEW MY APPOINTMENTS
            // ==================================================

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyAppointmentsPage(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                ),

                label: const Text(
                  'View My Appointments',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFF2589E8,
                  ),

                  side: const BorderSide(
                    color:
                        Color(0xFF2589E8),
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              const Color(0xFFDCE8F2),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFE7F3FF),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.person,
              size: 36,
              color:
                  Color(0xFF2589E8),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Dr. ${widget.doctor.name}',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF123E68),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.doctor.specialty,

                  style: const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF6685A0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _consultationOption({
    required String title,
    required IconData icon,
  }) {
    final selected =
        consultationType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          consultationType = title;
        });
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 15,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE7F3FF)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: selected
                ? const Color(0xFF2589E8)
                : const Color(0xFFDCE8F2),

            width: selected ? 1.5 : 1,
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,

              color: selected
                  ? const Color(
                      0xFF2589E8,
                    )
                  : const Color(
                      0xFF6685A0,
                    ),

              size: 25,
            ),

            const SizedBox(height: 6),

            Text(
              title,

              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,

                color: selected
                    ? const Color(
                        0xFF2589E8,
                      )
                    : const Color(
                        0xFF456174,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDay(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }

  String _shortMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}