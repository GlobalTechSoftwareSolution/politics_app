import 'package:flutter/material.dart';
import 'pending_users_screen.dart';
import 'admin_service.dart';

class AdminDashboard extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const AdminDashboard({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _adminService.getUserProfile();
      setState(() {
        _userProfile = profile['user'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              if (_userProfile != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_userProfile!['fullname']}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin Panel',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),

              // Admin actions
              const Text(
                'Admin Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Pending users card
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.group, color: Colors.blue),
                  title: const Text(
                    'Manage Pending Users',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Review and approve new user registrations',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PendingUsersScreen(
                          userEmail: widget.userEmail,
                          userPassword: widget.userPassword,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Profile card
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: _userProfile != null
                      ? Text(_userProfile!['email'])
                      : const Text('Loading...'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Show profile details
                    if (_userProfile != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('User Profile'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${_userProfile!['fullname']}'),
                              Text('Email: ${_userProfile!['email']}'),
                              Text('Role: ${_userProfile!['role']}'),
                              Text(
                                'Status: ${_userProfile!['is_approved'] ? 'Approved' : 'Pending'}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
