import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

import '../../models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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
        specialty.isNotEmpty &&
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
    if (accessToken != null)
      'Authorization': 'Bearer $accessToken',
  },
);

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Handles APIs returning either:
      // [ {...}, {...} ]
      // OR
      // { "results": [ {...}, {...} ] }

      final List<dynamic> data =
          decoded is List
              ? decoded
              : decoded['results'] ?? [];

      return data
          .map(
            (json) => Doctor.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load doctors: ${response.statusCode}',
    );
  }

  Future<Map<String, String>> _authHeaders() async {
  final token =
      await AuthService.getAccessToken();

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


Future<List<Map<String, dynamic>>>
    fetchMedicalRecords() async {
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

    final List<dynamic> data =
        decoded is List
            ? decoded
            : decoded['results'] ?? [];

    return data
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  throw Exception(
    'Failed to load medical records: '
    '${response.statusCode}',
  );


}
  Future<Map<String, dynamic>> fetchDoctorDashboard() async {
  final uri = Uri.parse('$baseUrl/api/dashboard/doctor/');

  final response = await http.get(
    uri,
    headers: await _authHeaders(),
  );

  print('Doctor Dashboard API: $uri');
  print('Status: ${response.statusCode}');
  print('Response: ${response.body}');

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  throw Exception(
    'Failed to load doctor dashboard: ${response.statusCode}',
  );
}

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

      final List<dynamic> data =
          decoded is List
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
}

