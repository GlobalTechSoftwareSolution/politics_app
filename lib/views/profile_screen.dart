import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'dart:convert';
import 'login_screen.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const ProfileScreen({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAdmin = false;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadProfileData();
  }

  Future<void> _checkUserRole() async {
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
          _isAdmin = isSuperuser || isStaff;
          _profileData = profile;
        });
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<void> _loadProfileData() async {
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
        setState(() {
          _profileData = profile;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
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
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _profileData?['email'] ?? widget.userEmail,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isAdmin ? 'Administrator' : 'User',
                            style: TextStyle(
                              fontSize: 18,
                              color: _isAdmin ? Colors.green : Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_profileData != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Member since: ${_formatDate(_profileData!['created_at'])}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Profile information section
                    if (_profileData != null) ...[
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Email',
                                _profileData!['email'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Full Name',
                                _profileData!['fullname'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Role',
                                _profileData!['role'] ?? 'user',
                              ),
                              _buildInfoRow(
                                'Status',
                                _profileData!['is_approved'] == true
                                    ? 'Approved'
                                    : 'Pending',
                              ),
                              _buildInfoRow(
                                'User Type',
                                _profileData!['is_user'] == true
                                    ? 'User'
                                    : 'Admin',
                              ),
                              _buildInfoRow(
                                'Super User',
                                _profileData!['is_superuser'] == true
                                    ? 'Yes'
                                    : 'No',
                              ),
                              _buildInfoRow(
                                'Staff Access',
                                _profileData!['is_staff'] == true
                                    ? 'Yes'
                                    : 'No',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Profile options
                    const Text(
                      'Profile Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[700]),
                        title: const Text('Logout'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
