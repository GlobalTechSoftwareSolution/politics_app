import 'package:flutter/material.dart';
import 'admin_service.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();

  // Static method to set user credentials from login
  static void setUserCredentials(String email, String password) {
    _userEmail = email;
    _userPassword = password;
  }

  static String _userEmail = '';
  static String _userPassword = '';
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _pendingUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load pending users after widget is fully initialized
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the credentials from the static variables
      final email = PendingUsersScreen._userEmail;
      final password = PendingUsersScreen._userPassword;

      print('=== PENDING USERS LOAD ===');
      print('Email: $email');
      print('Password length: ${password.length}');

      if (email.isEmpty || password.isEmpty) {
        throw Exception('User credentials not available. Please log in first.');
      }

      final users = await _adminService.getPendingUsers(email, password);
      setState(() {
        _pendingUsers = users;
      });
    } catch (e) {
      print('Error loading pending users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading pending users: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(int userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _adminService.approveUser(
        userId,
        PendingUsersScreen._userPassword,
        PendingUsersScreen._userEmail,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'User approved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the list
      await _loadPendingUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
          ? const Center(
              child: Text(
                'No pending users',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPendingUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingUsers.length,
                itemBuilder: (context, index) {
                  final user = _pendingUsers[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user['fullname'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(user['email'] ?? 'No email'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.group, color: Colors.green),
                              const SizedBox(width: 8),
                              Text('Role: ${user['role'] ?? 'user'}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registered: ${_formatDate(user['created_at'])}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approveUser(user['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Approve User',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Show more details
                                    _showUserDetails(user);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name: ${user['fullname'] ?? 'Unknown'}'),
            Text('Email: ${user['email'] ?? 'No email'}'),
            Text('Role: ${user['role'] ?? 'user'}'),
            Text('User ID: ${user['id'] ?? 'Unknown'}'),
            Text('Registered: ${_formatDate(user['created_at'])}'),
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
}
