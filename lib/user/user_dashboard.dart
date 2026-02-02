import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import '../views/content_management_screen.dart';
import '../admin/pending_users_screen.dart';
import '../views/login_screen.dart';
import '../views/user_add_content_screen.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:convert' as utf8;
import 'dart:convert' as base64;
import 'dart:convert';

class UserDashboard extends StatefulWidget {
  final String? userEmail;
  final String? userPassword;

  const UserDashboard({super.key, this.userEmail, this.userPassword});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String _userEmail = '';
  String _userPassword = '';

  @override
  void initState() {
    super.initState();
    // Set credentials from constructor if provided
    if (widget.userEmail != null && widget.userPassword != null) {
      _userEmail = widget.userEmail!;
      _userPassword = widget.userPassword!;
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
      print('URL: ${Constants.activeInfoEndpoint}');
      print('Email: $_userEmail');
      print('Password length: ${_userPassword.length}');
      print('Password: ${_userPassword.isNotEmpty ? '***' : 'EMPTY'}');

      // Use custom headers as expected by the backend
      final response = await http.get(
        Uri.parse(Constants.activeInfoEndpoint),
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserAddContentScreen(),
            ),
          );
        },
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
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
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
                  Text(
                    _userEmail.isNotEmpty ? _userEmail : 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'User',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserAccountSettingsScreen(
                        userEmail: _userEmail,
                        userPassword: _userPassword,
                      ),
                    ),
                  );
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
        Uri.parse(Constants.activeInfoEndpoint),
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
    final submittedBy =
        item['submitted_by_name'] ??
        (item['submitted_by'] as Map<String, dynamic>?)?['fullname'] ??
        'user';
    final imageUrl = item['image'];
    final submittedAt =
        (item['submitted_by'] as Map<String, dynamic>?)?['created_at'] ?? '';

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
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl.startsWith('http')
                      ? imageUrl
                      : '${Constants.imageBaseUrl}$imageUrl',
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
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                  child: Icon(Icons.info_outline, size: 80, color: Colors.blue),
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
    final submittedBy =
        (item['submitted_by'] as Map<String, dynamic>?)?['fullname'] ?? 'user';
    final submittedByEmail =
        (item['submitted_by'] as Map<String, dynamic>?)?['email'] ?? '';
    final submittedAt =
        (item['submitted_by'] as Map<String, dynamic>?)?['created_at'] ?? '';
    final approvedAt = item['approved_at'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Information Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                    imageUrl.startsWith('http')
                        ? imageUrl
                        : '${Constants.imageBaseUrl}$imageUrl',
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

// User Account Settings Screen
class UserAccountSettingsScreen extends StatefulWidget {
  final String? userEmail;
  final String? userPassword;

  const UserAccountSettingsScreen({
    super.key,
    this.userEmail,
    this.userPassword,
  });

  @override
  State<UserAccountSettingsScreen> createState() =>
      _UserAccountSettingsScreenState();
}

class _UserAccountSettingsScreenState extends State<UserAccountSettingsScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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

  Future<void> _loadUserProfile() async {
    if (widget.userEmail == null || widget.userPassword == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final profile = await _getUserProfile(
        widget.userEmail!,
        widget.userPassword!,
      );
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _getUserProfile(
    String email,
    String password,
  ) async {
    final url = Uri.parse(Constants.profileEndpoint);
    final authString = '$email:$password';
    final authBase64 = base64.base64Encode(utf8.utf8.encode(authString));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $authBase64',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAccountSettingsContent(),
    );
  }

  Widget _buildAccountSettingsContent() {
    if (_userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'User Profile Not Available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to view your profile',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final fullname = _userProfile!['fullname'] ?? 'User';
    final email = _userProfile!['email'] ?? widget.userEmail ?? 'No email';
    final role = _userProfile!['role'] ?? 'user';
    final isApproved = _userProfile!['is_approved'] ?? false;
    final createdAt = _userProfile!['created_at'] ?? '';
    final approvalDate = _userProfile!['approval_date'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullname,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.blue[100],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Account Information
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          // Account Details Cards
          _buildInfoCard(
            Icons.email,
            'Email Address',
            email,
            'This is your primary email address',
          ),
          _buildInfoCard(
            Icons.person,
            'Full Name',
            fullname,
            'Your display name in the application',
          ),
          _buildInfoCard(
            Icons.badge,
            'Account Type',
            role.toUpperCase(),
            'Your account role and permissions',
          ),
          _buildInfoCard(
            Icons.verified_user,
            'Account Status',
            isApproved ? 'Approved' : 'Pending Approval',
            isApproved
                ? 'Your account has been approved'
                : 'Your account is pending admin approval',
            color: isApproved ? Colors.green : Colors.orange,
          ),

          const SizedBox(height: 16),

          // System Information
          const Text(
            'System Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            Icons.calendar_today,
            'Member Since',
            _formatDate(createdAt),
            'Date when your account was created',
          ),
          if (approvalDate != null)
            _buildInfoCard(
              Icons.check_circle,
              'Approved On',
              _formatDate(approvalDate),
              'Date when your account was approved',
            ),

          const SizedBox(height: 24),

          // Actions
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.blue[900]),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle password change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password change feature coming soon'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue[900]),
                    title: const Text('Notification Settings'),
                    subtitle: const Text(
                      'Manage your notification preferences',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings coming soon'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.help, color: Colors.blue[900]),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help with using the app'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle help & support
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support coming soon'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Clear saved credentials
                await authService.clearCredentials();

                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    String description, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Colors.blue[900], size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
