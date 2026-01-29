import 'package:flutter/material.dart';
import 'mla_mp_list_screen.dart';
import 'map_screen.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import '../services/news_service.dart';
import '../admin/admin_dashboard.dart';
import '../admin/pending_users_screen.dart';
import 'login_screen.dart';
import '../admin/admin_service.dart';
import 'content_management_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as utf8;
import 'dart:convert' as base64;
import 'dart:convert';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  final String? userEmail;
  final String? userPassword;

  const DashboardScreen({super.key, this.userEmail, this.userPassword});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  bool _isAdmin = false; // Check if user is admin
  String _userEmail = '';
  String _userPassword = '';

  @override
  void initState() {
    super.initState();
    // Set credentials from constructor if provided
    if (widget.userEmail != null && widget.userPassword != null) {
      _userEmail = widget.userEmail!;
      _userPassword = widget.userPassword!;
      // Check admin status after a short delay to allow UI to build
      Future.delayed(const Duration(milliseconds: 100), _checkUserRole);
    }
    // Initialize news without setState to avoid initial jank
    _initializeNews();
  }

  // Initialize news without triggering setState during build
  Future<void> _initializeNews() async {
    try {
      final news = await NewsService.fetchPoliticsNews();
      if (mounted) {
        setState(() {
          _newsList = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching news: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fetch active info from API
  void _fetchActiveInfo() async {
    if (!mounted) return;

    // Validate credentials before making API call
    if (_userEmail.isEmpty || _userPassword.isEmpty) {
      print('=== CREDENTIAL VALIDATION FAILED ===');
      print('Email is empty: ${_userEmail.isEmpty}');
      print('Password is empty: ${_userPassword.isEmpty}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first to access active information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Log the exact API call being made
      print('=== ACTIVE-INFO API CALL ===');
      print('URL: http://10.0.2.2:8000/api/active-info/');
      print('Email: $_userEmail');
      print('Password length: ${_userPassword.length}');
      print('Password: ${_userPassword.isNotEmpty ? '***' : 'EMPTY'}');

      // Use custom headers as expected by the backend
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/active-info/'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Email': _userEmail,
          'X-User-Password': _userPassword,
        },
      );

      print('=== ACTIVE-INFO RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        setState(() {
          _newsList = []; // Clear news list since we're showing active info
          _isLoading = false;
        });
      } else if (response.statusCode == 400) {
        // Handle the specific "Email and password required" error
        final errorData = jsonDecode(response.body);
        print('Authentication error: ${errorData['error']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${errorData['error']}'),
            backgroundColor: Colors.red,
          ),
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fallback to news if active-info fails
        final news = await NewsService.fetchPoliticsNews();
        if (!mounted) return;

        setState(() {
          _newsList = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching active info: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load active info')),
      );
    }
  }

  // Fetch news from API
  void _fetchNews() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final news = await NewsService.fetchPoliticsNews();
      if (!mounted) return;

      setState(() {
        _newsList = news;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching news: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load news')));
    }
  }

  void _navigateToCreatePost() {
    // Show dialog for creating a new post
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Post'),
          content: const TextField(
            decoration: InputDecoration(hintText: 'Write your thoughts...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle post creation
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache the bottom navigation bar to prevent unnecessary rebuilds
    final bottomNavBar = BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.content_paste),
          label: 'Content',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group_add),
          label: 'Approve Users',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politics Dashboard'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ContentManagementScreen();
      case 2:
        return const PendingUsersScreen();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchNews();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              const Text(
                'Welcome back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Active Info Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _fetchActiveInfo();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Active info loading or content
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                // Active info display - use stored data instead of FutureBuilder
                _buildActiveInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to set user credentials (called from login)
  void setUserCredentials(String email, String password) {
    setState(() {
      _userEmail = email;
      _userPassword = password;
    });
  }

  void _checkUserRole() async {
    // Only check if we have credentials
    print('=== CHECKING USER ROLE ===');
    print('Email: $_userEmail');
    print('Password length: ${_userPassword.length}');

    if (_userEmail.isEmpty || _userPassword.isEmpty) {
      print('Credentials are empty, setting admin to false');
      setState(() {
        _isAdmin = false;
      });
      return;
    }

    try {
      final adminService = AdminService();
      // Try to get pending users to check if user has admin access
      print('=== TRYING PENDING USERS API ===');
      final pendingUsers = await adminService.getPendingUsers(
        _userEmail,
        _userPassword,
      );
      print(
        'Admin check successful, user is admin. Found ${pendingUsers.length} pending users',
      );
      setState(() {
        _isAdmin = true;
      });
      print('=== ADMIN STATUS SET TO TRUE (PENDING USERS) ===');
    } catch (e) {
      print('Pending users API failed: $e');
      print('=== TRYING PROFILE API FOR SUPERUSER CHECK ===');
      // Check if this is a superuser by trying to get user profile
      try {
        final profile = await _getUserProfile(_userEmail, _userPassword);
        print('Profile API successful');
        print('Profile data: $profile');
        print('Is superuser: ${profile['is_superuser']}');
        print('Is staff: ${profile['is_staff']}');

        final isSuperuser = profile['is_superuser'] == true;
        final isStaff = profile['is_staff'] == true;

        setState(() {
          _isAdmin = isSuperuser || isStaff;
        });

        print('=== ADMIN STATUS SET TO: ${isSuperuser || isStaff} ===');
        print('Superuser: $isSuperuser, Staff: $isStaff');
      } catch (profileError) {
        print('Profile API also failed: $profileError');
        // User is not admin, keep _isAdmin as false
        setState(() {
          _isAdmin = false;
        });
        print('=== ADMIN STATUS SET TO FALSE (BOTH APIS FAILED) ===');
      }
    }
  }

  // Helper method to get user profile
  Future<Map<String, dynamic>> _getUserProfile(
    String email,
    String password,
  ) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/profile/');
    final authString = '$email:$password';
    final authBase64 = base64.base64Encode(utf8.utf8.encode(authString));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $authBase64',
    };

    print('=== PROFILE API CALL ===');
    print('URL: $url');
    print('Email: $email');
    print('Password length: ${password.length}');
    print('Auth base64: $authBase64');

    final response = await http.get(url, headers: headers);

    print('=== PROFILE RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
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
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Active Citizen',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile options
            Card(
              child: ListTile(
                leading: Icon(Icons.settings, color: Colors.blue[900]),
                title: const Text('Account Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle settings
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.blue[900]),
                title: const Text('My Activity'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle activity
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.help, color: Colors.blue[900]),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle help
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.blue[900]),
                title: const Text('Logout'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  // Clear saved credentials
                  await authService.clearCredentials();

                  // Navigate to login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveInfoSection() {
    // Fetch active info data using custom headers as expected by backend
    return FutureBuilder(
      future: http.get(
        Uri.parse('http://10.0.2.2:8000/api/active-info/'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Email': _userEmail,
          'X-User-Password': _userPassword,
        },
      ),
      builder: (context, snapshot) {
        print('=== ACTIVE-INFO SECTION ===');
        print('Connection State: ${snapshot.connectionState}');
        print('Has Error: ${snapshot.hasError}');
        print('Has Data: ${snapshot.hasData}');
        print('Email: $_userEmail');
        print('Password: ${_userPassword.isNotEmpty ? '***' : 'EMPTY'}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          print('Active-info API response status: ${response.statusCode}');
          print('Active-info API response body: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            // Check if data is a list or single object
            if (data is List) {
              return _buildActiveInfoListDisplay(data);
            } else {
              return _buildActiveInfoDisplay(data);
            }
          } else {
            return Center(
              child: Text(
                'API Error: ${response.statusCode} - ${response.reasonPhrase}',
              ),
            );
          }
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildActiveInfoListDisplay(List<dynamic> dataList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Active Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // List of active info cards (single column)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index];
              return Column(
                children: [
                  _buildActiveInfoCard(item, index),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveInfoCard(Map<String, dynamic> item, int index) {
    final heading = item['heading'] ?? 'No heading';
    final description = item['description'] ?? 'No description';
    final submittedBy = item['submitted_by']['fullname'] ?? 'Unknown';
    final imageUrl = item['image'];
    final submittedAt = item['submitted_by']['created_at'] ?? '';

    return GestureDetector(
      onTap: () {
        // Navigate to detailed view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ActiveInfoDetailScreen(item: item, index: index + 1),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  'http://10.0.2.2:8000$imageUrl',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.info_outline, size: 40, color: Colors.blue),
                ),
              ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description preview
                  Text(
                    description.length > 80
                        ? '${description.substring(0, 80)}...'
                        : description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Footer info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          submittedBy,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveInfoDisplay(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the raw JSON data in a formatted way
            const Text(
              'Active Info Response:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jsonEncode(data),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detailed view screen for active info
class ActiveInfoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const ActiveInfoDetailScreen({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final heading = item['heading'] ?? 'No heading';
    final description = item['description'] ?? 'No description';
    final imageUrl = item['image'];
    final submittedBy = item['submitted_by']['fullname'] ?? 'Unknown';
    final submittedByEmail = item['submitted_by']['email'] ?? '';
    final submittedAt = item['submitted_by']['created_at'] ?? '';
    final approvedAt = item['approved_at'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Information Details'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://10.0.2.2:8000$imageUrl',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Title
              Text(
                heading,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Information section
              const Text(
                'Information Details:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),

              // Submitted by
              _buildInfoRow(Icons.person, 'Submitted By', submittedBy),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, 'Email', submittedByEmail),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                'Submitted On',
                _formatDate(submittedAt),
              ),
              const SizedBox(height: 8),
              if (approvedAt.isNotEmpty)
                _buildInfoRow(
                  Icons.check_circle,
                  'Approved On',
                  _formatDate(approvedAt),
                ),

              const SizedBox(height: 30),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back to List',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
