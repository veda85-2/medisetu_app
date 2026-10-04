import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AppointmentDetailsPage
    extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailsPage> createState() =>
      _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState
    extends State<AppointmentDetailsPage> {
  final ApiService _apiService =
      ApiService();

  bool isCancelling = false;

  Map<String, dynamic> get appointment =>
      widget.appointment;

  @override
  Widget build(BuildContext context) {
    final doctor =
        appointment['doctor_detail']
            is Map
        ? Map<String, dynamic>.from(
            appointment['doctor_detail'],
          )
        : null;

    final doctorName =
        doctor?['name'] ??
        appointment['doctor_name'] ??
        'Doctor';

    final specialty =
        doctor?['specialization'] ??
        doctor?['specialty'] ??
        'Medical Specialist';

    final date =
        appointment['appointment_date']
                ?.toString() ??
            '';

    final time =
        appointment['appointment_time']
                ?.toString() ??
            '';

    final reason =
        appointment['reason']
                ?.toString() ??
            'Consultation';

    final status =
        appointment['status']
                ?.toString()
                .toUpperCase() ??
            '';

    final appointmentId =
        appointment['id'];

    final isUpcoming =
        status == 'BOOKED';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FA),

      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFFE4F4F0),
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color:
                          Color(0xFF197A6B),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    doctorName.toString(),
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF123E68),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    specialty.toString(),
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _statusBadge(status),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Appointment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 12),

            _infoCard(
              Icons.calendar_today_outlined,
              'Date',
              date,
            ),

            _infoCard(
              Icons.access_time,
              'Time',
              time,
            ),

            _infoCard(
              Icons.medical_information_outlined,
              'Reason',
              reason,
            ),

            _infoCard(
              Icons.confirmation_number_outlined,
              'Appointment ID',
              appointmentId != null
                  ? 'MED-$appointmentId'
                  : '-',
            ),

            if (isUpcoming &&
                appointmentId != null) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      isCancelling
                          ? null
                          : () =>
                              _cancelAppointment(
                                appointmentId,
                              ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red.shade600,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              14),
                    ),
                  ),
                  child: isCancelling
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFE4F4F0),
              borderRadius:
                  BorderRadius.circular(
                      12),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF197A6B),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty
                      ? '-'
                      : value,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF123E68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(
    String status,
  ) {
    final isCompleted =
        status == 'COMPLETED';

    final isCancelled =
        status == 'CANCELLED';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color: isCompleted
            ? Colors.green.shade50
            : isCancelled
                ? Colors.red.shade50
                : Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted
            ? 'Completed'
            : isCancelled
                ? 'Cancelled'
                : 'Upcoming',
        style: TextStyle(
          fontWeight:
              FontWeight.bold,
          color: isCompleted
              ? Colors.green.shade700
              : isCancelled
                  ? Colors.red.shade700
                  : Colors.orange.shade700,
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(
    dynamic id,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel Appointment?',
          ),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('No'),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isCancelling = true;
    });

    try {
      final success =
          await _apiService
              .cancelAppointment(
        int.parse(id.toString()),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Appointment cancelled successfully',
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to cancel appointment',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to cancel appointment: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCancelling = false;
        });
      }
    }
  }
}