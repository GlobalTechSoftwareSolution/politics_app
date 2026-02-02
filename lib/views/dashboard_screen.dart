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
import 'add_content_screen.dart';
import 'splash2_screen.dart';
import 'krishna_profile_screen.dart';
import 'profile_screen.dart';
import 'user_profile_screen.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
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
  bool _showSplash = true;
  bool _isAdmin = false; // Check if user is admin
  String _userEmail = '';
  String _userPassword = '';
  bool _isSearching = false;
  String _searchQuery = '';
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];

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
    if (_showSplash) {
      return Splash2Screen(
        onSplashComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    // Cache the bottom navigation bar to prevent unnecessary rebuilds
    final bottomNavBar = BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        print('=== BOTTOM NAVIGATION TAPPED ===');
        print('Previous Index: $_currentIndex');
        print('New Index: $index');
        setState(() {
          _currentIndex = index;
        });
        print('State Updated, Current Index: $_currentIndex');
      },
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        if (_isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.content_paste),
            label: 'Content',
          ),
        if (_isAdmin)
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
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                }
              });
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KrishnaProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/krishna-byre-gowda-1528518631.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.blue[900],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                        // Trigger rebuild of active info section
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContentScreen()),
          );
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    print('=== BUILD BODY CALLED ===');
    print('Current Index: $_currentIndex');
    print('Is Admin: $_isAdmin');
    print('User Email: $_userEmail');

    switch (_currentIndex) {
      case 0:
        print('Building Home Content');
        return _buildHomeContent();
      case 1:
        // For non-admin users, index 1 is Profile
        // For admin users, index 1 is Content Management
        if (_isAdmin) {
          print('Building Content Management Screen');
          return const ContentManagementScreen();
        } else {
          print('Building User Profile Screen');
          return UserProfileScreen(
            userEmail: _userEmail,
            userPassword: _userPassword,
          );
        }
      case 2:
        // For admin users, index 2 is Pending Users
        if (_isAdmin) {
          print('Building Pending Users Screen');
          return PendingUsersScreen(
            userEmail: _userEmail,
            userPassword: _userPassword,
          );
        } else {
          // For non-admin users, index 2 doesn't exist, fallback to home
          print('Building Default Home Content (invalid index for non-admin)');
          return _buildHomeContent();
        }
      case 3:
        // For admin users, index 3 is Profile
        if (_isAdmin) {
          print('Building Admin Profile Screen');
          return ProfileScreen(
            userEmail: _userEmail,
            userPassword: _userPassword,
          );
        } else {
          // For non-admin users, index 3 doesn't exist, fallback to home
          print('Building Default Home Content (invalid index for non-admin)');
          return _buildHomeContent();
        }
      default:
        print('Building Default Home Content');
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (_showSplash) {
      return Splash2Screen(
        onSplashComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _showSplash = true;
        });
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _fetchActiveInfo();
        }
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
    final url = Uri.parse(Constants.profileEndpoint);

    // Use custom headers as expected by the backend
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Email': email,
      'X-User-Password': password,
    };

    print('=== PROFILE API CALL ===');
    print('URL: $url');
    print('Email: $email');
    print('Password length: ${password.length}');
    print('Password: ${password.isNotEmpty ? '***' : 'EMPTY'}');

    final response = await http.get(url, headers: headers);

    print('=== PROFILE RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      print('Profile error: ${errorData['error']}');
      throw Exception('Profile API error: ${errorData['error']}');
    } else {
      throw Exception(
        'Failed to load user profile: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // New helper method to validate credentials
  bool _areCredentialsValid() {
    return _userEmail.isNotEmpty && _userPassword.isNotEmpty;
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
          print('=== ACTIVE-INFO ERROR ===');
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          print('=== ACTIVE-INFO RESPONSE ===');
          print('Status Code: ${response.statusCode}');
          print('Headers: ${response.headers}');
          print('Body: ${response.body}');
          print('Content Length: ${response.contentLength} bytes');
          print('Reason Phrase: ${response.reasonPhrase}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('=== ACTIVE-INFO SUCCESS ===');
            print('Response Data: $data');
            print('Data Type: ${data.runtimeType}');
            print('Data Length: ${data is List ? data.length : 'Not a list'}');

            // Store original data and filter if needed
            if (data is List) {
              // Store all data
              _allData = data;
              // Apply search filter if there's a query
              List<dynamic> displayData = data;
              if (_searchQuery.isNotEmpty) {
                displayData = data.where((item) {
                  final heading = (item['heading'] ?? '')
                      .toString()
                      .toLowerCase();
                  final description = (item['description'] ?? '')
                      .toString()
                      .toLowerCase();
                  final submittedBy =
                      (item['submitted_by_name'] ??
                              item['submitted_by']['fullname'] ??
                              '')
                          .toString()
                          .toLowerCase();

                  return heading.contains(_searchQuery) ||
                      description.contains(_searchQuery) ||
                      submittedBy.contains(_searchQuery);
                }).toList();
              }

              if (displayData.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text(
                      'Found nothing',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }

              return _buildActiveInfoListDisplay(displayData);
            } else {
              return _buildActiveInfoDisplay(data);
            }
          } else {
            print('=== ACTIVE-INFO FAILED ===');
            print('Status Code: ${response.statusCode}');
            print('Reason Phrase: ${response.reasonPhrase}');
            print('Response Body: ${response.body}');
            return Center(
              child: Text(
                'API Error: ${response.statusCode} - ${response.reasonPhrase}',
              ),
            );
          }
        } else {
          print('=== ACTIVE-INFO NO DATA ===');
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl.startsWith('http')
                      ? imageUrl
                      : '${Constants.imageBaseUrl}$imageUrl',
                  height: 200,
                  width: double.infinity,
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
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
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
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
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
        item['submitted_by_email'] ??
        (item['submitted_by'] as Map<String, dynamic>?)?['email'] ??
        '';
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
                        backgroundColor: Colors.green[600],
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

// Account Settings Screen
// This screen handles user account settings and profile information
class AccountSettingsScreen extends StatefulWidget {
  final String? userEmail;
  final String? userPassword;
  final bool isAdmin;

  const AccountSettingsScreen({
    super.key,
    this.userEmail,
    this.userPassword,
    required this.isAdmin,
  });

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
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
    print('=== LOADING USER PROFILE IN SETTINGS ===');
    print('Email from widget: ${widget.userEmail}');
    print(
      'Password from widget: ${widget.userPassword != null ? '***' : 'NULL'}',
    );
    print('Email length: ${widget.userEmail?.length ?? 0}');
    print('Password length: ${widget.userPassword?.length ?? 0}');

    if (widget.userEmail == null ||
        widget.userPassword == null ||
        widget.userEmail!.isEmpty ||
        widget.userPassword!.isEmpty) {
      print('=== CREDENTIALS MISSING IN SETTINGS ===');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('=== CALLING PROFILE API FROM SETTINGS ===');
      final profile = await _getUserProfile(
        widget.userEmail!,
        widget.userPassword!,
      );
      print('=== PROFILE API SUCCESS IN SETTINGS ===');
      print('Profile data: $profile');
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('=== PROFILE API ERROR IN SETTINGS ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
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

    // Use custom headers as expected by the backend
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Email': email,
      'X-User-Password': password,
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Profile API error: ${errorData['error']}');
    } else {
      throw Exception(
        'Failed to load user profile: ${response.statusCode} - ${response.reasonPhrase}',
      );
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
    final isSuperuser = _userProfile!['is_superuser'] ?? false;
    final isStaff = _userProfile!['is_staff'] ?? false;
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
                            const SizedBox(width: 8),
                            if (isSuperuser)
                              Chip(
                                label: const Text(
                                  'SUPERUSER',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.green[100],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            if (isStaff)
                              Chip(
                                label: const Text(
                                  'STAFF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.orange[100],
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
          _buildInfoCard(
            Icons.security,
            'Security Level',
            isSuperuser ? 'High (Superuser)' : 'Standard',
            isSuperuser
                ? 'Full system access and privileges'
                : 'Standard user privileges',
            color: isSuperuser ? Colors.red : Colors.blue,
          ),

          const SizedBox(height: 24),

          // Raw JSON Data
          const Text(
            'Raw Account Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JSON Response:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      JsonEncoder.withIndent('  ').convert(_userProfile),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

          // Admin Actions (if user is admin)
          if (widget.isAdmin)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.group_add,
                            color: Colors.red[900],
                          ),
                          title: const Text('Manage Users'),
                          subtitle: const Text(
                            'Approve pending users and manage accounts',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            // Store credentials in local variables to avoid scope issues

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PendingUsersScreen(
                                  userEmail: email,
                                  userPassword: widget.userPassword ?? '',
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.content_paste,
                            color: Colors.red[900],
                          ),
                          title: const Text('Content Management'),
                          subtitle: const Text(
                            'Manage active information and content',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ContentManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
