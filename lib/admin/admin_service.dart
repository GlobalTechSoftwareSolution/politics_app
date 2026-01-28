import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  final String baseUrl = 'http://10.0.2.2:8000';

  // Get pending users (admin only)
  Future<List<dynamic>> getPendingUsers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/pending-users/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer superpassword123', // Use the token from login
      },
    );

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
  Future<Map<String, dynamic>> approveUser(int userId) async {
    final url = Uri.parse('$baseUrl/api/approve-user/$userId/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve user');
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
}
