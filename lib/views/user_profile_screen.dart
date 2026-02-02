import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const UserProfileScreen({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final url = Uri.parse(Constants.profileEndpoint);
      final headers = {
        'Content-Type': 'application/json',
        'X-User-Email': widget.userEmail,
        'X-User-Password': widget.userPassword,
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        final isSuperuser = profile['is_superuser'] == true;
        final isStaff = profile['is_staff'] == true;

        setState(() {
          _userProfile = profile;
          _isAdmin = isSuperuser || isStaff;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await authService.clearCredentials();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _userProfile?['fullname'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _userProfile?['email'] ?? widget.userEmail,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isAdmin
                                  ? Colors.green[100]
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isAdmin ? 'Administrator' : 'User',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isAdmin
                                    ? Colors.green[800]
                                    : Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Profile details card
                    if (_userProfile != null) ...[
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildDetailRow('Email', _userProfile!['email']),
                              _buildDetailRow(
                                'Full Name',
                                _userProfile!['fullname'] ?? 'N/A',
                              ),
                              _buildDetailRow('Role', _userProfile!['role']),
                              _buildDetailRow(
                                'Status',
                                _userProfile!['is_approved'] == true
                                    ? 'Approved'
                                    : 'Pending',
                              ),
                              _buildDetailRow(
                                'User Type',
                                _userProfile!['is_user'] == true
                                    ? 'Regular User'
                                    : 'Admin',
                              ),
                              if (_userProfile!['created_at'] != null &&
                                  _userProfile!['created_at'].isNotEmpty)
                                _buildDetailRow(
                                  'Member Since',
                                  _formatDate(_userProfile!['created_at']),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
