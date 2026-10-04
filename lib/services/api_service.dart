import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http:// 192.168.1.6:8000';

  // =========================
  // AUTH HEADERS
  // =========================

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // FIND DOCTORS
  // =========================

  Future<List<Doctor>> fetchDoctor({
    String? search,
    String? specialty,
  }) async {
    final queryParameters = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (specialty != null &&
        specialty.trim().isNotEmpty &&
        specialty != 'All') {
      queryParameters['specialty'] = specialty;
    }

    final uri = Uri.parse(
      '$baseUrl/api/doctors/',
    ).replace(
      queryParameters: queryParameters,
    );

    print('Doctor API: $uri');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      },
    );

    print('Doctor API Status: ${response.statusCode}');
    print('Doctor API Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : decoded['results'] ?? [];

      return data
          .map(
            (json) => Doctor.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load doctors: ${response.statusCode}',
    );
  }

  // =========================
  // MEDICAL RECORDS
  // =========================

  Future<List<Map<String, dynamic>>> fetchMedicalRecords() async {
    final uri = Uri.parse(
      '$baseUrl/api/medical-records/',
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    print('Medical Records API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : decoded['results'] ?? [];

      return data
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }

    throw Exception(
      'Failed to load medical records: ${response.statusCode}',
    );
  }

  // =========================
  // DOCTOR DASHBOARD
  // =========================

  Future<Map<String, dynamic>> fetchDoctorDashboard() async {
    final uri = Uri.parse(
      '$baseUrl/api/dashboard/doctor/',
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    print('Doctor Dashboard API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to load doctor dashboard: ${response.statusCode}',
    );
  }

  // =========================
  // PRESCRIPTIONS
  // =========================

  Future<List<Map<String, dynamic>>> fetchPrescriptions() async {
    final uri = Uri.parse(
      '$baseUrl/api/prescriptions/',
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    print('Prescriptions API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : decoded['results'] ?? [];

      return data
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }

    throw Exception(
      'Failed to load prescriptions: ${response.statusCode}',
    );
  }

  // =========================
  // CREATE APPOINTMENT
  // =========================

  Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required DateTime date,
    required String time,
    String reason = 'Consultation',
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments/',
    );

    final appointmentDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({
        'doctor_id': doctorId,
        'appointment_date': appointmentDate,
        'appointment_time': time,
        'reason': reason,
      }),
    );

    print('Create Appointment API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      return Map<String, dynamic>.from(decoded);
    }

    throw Exception(
      'Failed to create appointment: '
      '${response.statusCode} ${response.body}',
    );
  }

  // =========================
  // FETCH ALL APPOINTMENTS
  // =========================

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments/',
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    print('Appointments API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : decoded['results'] ?? [];

      return data
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }

    throw Exception(
      'Failed to load appointments: ${response.statusCode}',
    );
  }

  // =========================
  // FETCH SINGLE APPOINTMENT
  // =========================

  Future<Map<String, dynamic>> fetchAppointment(int id) async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments/$id/',
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    print('Appointment Details API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to load appointment: ${response.statusCode}',
    );
  }

  // =========================
  // CANCEL APPOINTMENT
  // =========================

  Future<bool> cancelAppointment(int id) async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments/$id/',
    );

    final response = await http.put(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({
        'status': 'CANCELLED',
      }),
    );

    print('Cancel Appointment API: $uri');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    return response.statusCode == 200;
  }
}