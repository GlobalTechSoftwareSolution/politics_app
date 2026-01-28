import 'dart:convert';
import 'dart:convert' as utf8;
import 'dart:convert' as base64;
import 'package:http/http.dart' as http;

class AdminService {
  final String baseUrl = 'http://10.0.2.2:8000';

  // Get pending users (admin only)
  Future<List<dynamic>> getPendingUsers(String email, String password) async {
    print(
      'AdminService.getPendingUsers called with email: $email, password length: ${password.length}',
    );

    final url = Uri.parse('http://10.0.2.2:8000/api/pending-users/');
    final headers = {
      'Content-Type': 'application/json',
      'X-Admin-Password': password, // Use the actual password from login
    };

    print('Making API call to: $url');
    print('With headers: $headers');

    final response = await http.get(url, headers: headers);

    print('Pending users API response status: ${response.statusCode}');
    print('Pending users API response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load pending users: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // Approve user (admin only)
  Future<Map<String, dynamic>> approveUser(int userId, String password) async {
    print(
      'AdminService.approveUser called with userId: $userId, password length: ${password.length}',
    );

    final url = Uri.parse('$baseUrl/api/approve-user/$userId/');
    final headers = {
      'Content-Type': 'application/json',
      'X-Admin-Password': password,
    };
    final body = jsonEncode({'password': password});

    print('Making approve user API call to: $url');
    print('With headers: $headers');
    print('With body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('Approve user API response status: ${response.statusCode}');
    print('Approve user API response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to approve user: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // Approve information (admin only)
  Future<Map<String, dynamic>> approveInfo(int infoId, String password) async {
    final url = Uri.parse('$baseUrl/api/approve-info/$infoId/');
    final headers = {
      'Content-Type': 'application/json',
      'X-Admin-Password': password,
    };
    final body = jsonEncode({'password': password});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve information');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final url = Uri.parse('$baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  // Helper method to encode credentials for Basic Auth
  String _encodeCredentials(String email, String password) {
    // The backend expects plain text credentials for Basic Auth
    // even though it stores hashed passwords in the database
    return base64.base64Encode(utf8.utf8.encode('$email:$password'));
  }
}
