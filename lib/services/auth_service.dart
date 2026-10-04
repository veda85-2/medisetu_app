import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const String baseUrl = 'http:// 192.168.1.6:8000/api/auth';

  // =========================
  // LOGIN
  // =========================

  

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final access = data['access'];
        final refresh = data['refresh'];

        if (access != null) {
          await prefs.setString('access_token', access);
        }

        if (refresh != null) {
          await prefs.setString('refresh_token', refresh);
        }

        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': _getErrorMessage(data, 'Login failed'),
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
        'error': e.toString(),
      };
    }
  }

  // =========================
  // REGISTER
  // =========================

static Future<Map<String, dynamic>> register({
  required String username,
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String role,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      }),
    );

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
        'Registration failed',
      ),
      'data': data,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Unable to connect to server',
      'error': e.toString(),
    };
  }
}
  // =========================
  // REFRESH TOKEN
  // =========================

  static Future<bool> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final refreshToken =
          prefs.getString('refresh_token');

      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200 &&
          data['access'] != null) {
        await prefs.setString(
          'access_token',
          data['access'],
        );

        return true;
      }

      await logout();
      return false;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // GET CURRENT USER
  // =========================

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final accessToken =
          prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Not logged in',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final data = _decodeResponse(response);
        print('ME STATUS: ${response.statusCode}');
    print('ME RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }

      // Try refreshing the token
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
          'Could not get user',
        ),
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
        'error': e.toString(),
      };
    }
  }

  // =========================
  // GET ACCESS TOKEN
  // =========================

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // =========================
  // RESPONSE DECODER
  // =========================

  static dynamic _decodeResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body,
      };
    }
  }

  // =========================
  // ERROR MESSAGE
  // =========================

  static String _getErrorMessage(
    dynamic data,
    String fallback,
  ) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        return data['detail'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }

      // Django validation errors
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    return fallback;
  }
}
