import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
       "http://127.0.0.1:8000/api/auth";

 
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 40));

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN URL: ${response.request?.url}');
      print('LOGIN RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is! Map<String, dynamic>) {
          return {
            'success': false,
            'message': 'Invalid response received from server.',
          };
        }

        final prefs = await SharedPreferences.getInstance();

        final access = data['access'];
        final refresh = data['refresh'];

        if (access != null) {
          await prefs.setString(
            'access_token',
            access.toString(),
          );
        }

        if (refresh != null) {
          await prefs.setString(
            'refresh_token',
            refresh.toString(),
          );
        }

        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': _getErrorMessage(
          data,
          'Login failed. Please check your username and password.',
        ),
        'data': data,
      };
    } catch (e) {
      print('LOGIN ERROR: $e');

      return {
        'success': false,
        'message': _connectionErrorMessage(e),
        'error': e.toString(),
      };
    }
  }

  // =========================================================
  // REGISTER
  // =========================================================

  static Future<Map<String, dynamic>> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username.trim(),
              'email': email.trim(),
              'password': password,
              'first_name': firstName.trim(),
              'last_name': lastName.trim(),
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 40));

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER URL: ${response.request?.url}');
      print('REGISTER RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': _getErrorMessage(
          data,
          'Registration failed.',
        ),
        'data': data,
      };
    } catch (e) {
      print('REGISTER ERROR: $e');

      return {
        'success': false,
        'message': _connectionErrorMessage(e),
        'error': e.toString(),
      };
    }
  }

  // =========================================================
  // REFRESH ACCESS TOKEN
  // =========================================================

  static Future<bool> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final refreshToken =
          prefs.getString('refresh_token');

      if (refreshToken == null ||
          refreshToken.isEmpty) {
        return false;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/refresh/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'refresh': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 40));

      print('REFRESH STATUS: ${response.statusCode}');
      print('REFRESH RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['access'] != null) {
        await prefs.setString(
          'access_token',
          data['access'].toString(),
        );

        return true;
      }

      await logout();
      return false;
    } catch (e) {
      print('REFRESH ERROR: $e');
      return false;
    }
  }

  // =========================================================
  // GET CURRENT USER
  // =========================================================

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final accessToken =
          prefs.getString('access_token');

      if (accessToken == null ||
          accessToken.isEmpty) {
        return {
          'success': false,
          'message': 'Not logged in',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/me/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 40));

      print('ME STATUS: ${response.statusCode}');
      print('ME URL: ${response.request?.url}');
      print('ME RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }

      // Token expired
      if (response.statusCode == 401) {
        final refreshed =
            await refreshAccessToken();

        if (refreshed) {
          return await getMe();
        }
      }

      return {
        'success': false,
        'message': _getErrorMessage(
          data,
          'Could not get user information.',
        ),
        'data': data,
      };
    } catch (e) {
      print('GET ME ERROR: $e');

      return {
        'success': false,
        'message': _connectionErrorMessage(e),
        'error': e.toString(),
      };
    }
  }

  // =========================================================
  // GET ACCESS TOKEN
  // =========================================================

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // =========================================================
  // SEND OTP
  // =========================================================

  static Future<bool> sendOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/send-otp/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
            }),
          )
          .timeout(const Duration(seconds: 40));

      print('OTP SEND STATUS: ${response.statusCode}');
      print('OTP SEND URL: ${response.request?.url}');
      print('OTP SEND RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception(
        _getErrorMessage(
          data,
          'Failed to send OTP.',
        ),
      );
    } catch (e) {
      print('OTP SEND ERROR: $e');

      throw Exception(
        _cleanException(e),
      );
    }
  }

  // =========================================================
  // VERIFY OTP
  // =========================================================

  static Future<bool> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-otp/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'otp': otp.trim(),
            }),
          )
          .timeout(const Duration(seconds: 40));

      print('OTP VERIFY STATUS: ${response.statusCode}');
      print('OTP VERIFY URL: ${response.request?.url}');
      print('OTP VERIFY RESPONSE: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          if (data['is_verified'] == true) {
            return true;
          }

          // Some backends may return success instead.
          if (data['success'] == true) {
            return true;
          }
        }
      }

      throw Exception(
        _getErrorMessage(
          data,
          'Invalid OTP code.',
        ),
      );
    } catch (e) {
      print('OTP VERIFY ERROR: $e');

      throw Exception(
        _cleanException(e),
      );
    }
  }

  // =========================================================
  // RESPONSE DECODER
  // =========================================================

  static dynamic _decodeResponse(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return {};
    }

    final contentType =
        response.headers['content-type'] ?? '';

    // JSON response
    if (contentType.contains('application/json')) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          'message': 'Server returned invalid JSON.',
          'status_code': response.statusCode,
        };
      }
    }

    // Server returned HTML or another non-JSON response.
    if (response.body.trim().startsWith('<')) {
      return {
        'message':
            'Server returned an HTML error page instead of JSON.',
        'status_code': response.statusCode,
      };
    }

    // Try JSON anyway.
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body.trim(),
        'status_code': response.statusCode,
      };
    }
  }

  // =========================================================
  // ERROR MESSAGE
  // =========================================================

  static String _getErrorMessage(
    dynamic data,
    String fallback,
  ) {
    if (data is String &&
        data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        return data['detail'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['error'] != null) {
        return data['error'].toString();
      }

      // Django validation errors
      for (final entry in data.entries) {
        final value = entry.value;

        if (value is List &&
            value.isNotEmpty) {
          return '${entry.key}: ${value.first}';
        }

        if (value is String &&
            value.trim().isNotEmpty) {
          return '${entry.key}: ${value}';
        }
      }
    }

    return fallback;
  }

  // =========================================================
  // CONNECTION ERROR
  // =========================================================

  static String _connectionErrorMessage(
    Object error,
  ) {
    final message = error.toString();

    if (message.contains('TimeoutException')) {
      return 'Server took too long to respond. Please try again.';
    }

    if (message.contains('SocketException')) {
      return 'Unable to connect to server. Check your internet connection.';
    }

    return 'Unable to connect to server.';
  }

  // =========================================================
  // CLEAN EXCEPTION
  // =========================================================

  static String _cleanException(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}