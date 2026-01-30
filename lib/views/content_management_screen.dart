import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  List<Map<String, dynamic>> _pendingContent = [];
  bool _isLoading = false;
  String _adminEmail = '';
  String _adminPassword = '';

  @override
  void initState() {
    super.initState();
    _loadCredentialsAndContent();
  }

  Future<void> _loadCredentialsAndContent() async {
    try {
      final credentials = await authService.getSavedCredentials();
      if (credentials != null) {
        setState(() {
          _adminEmail = credentials['email'] ?? '';
          _adminPassword = credentials['password'] ?? '';
        });
        print('=== LOADED CREDENTIALS FROM AUTH SERVICE ===');
        print('Email: $_adminEmail');
        print('Password length: ${_adminPassword.length}');
      } else {
        print('=== NO CREDENTIALS FOUND IN AUTH SERVICE ===');
      }
    } catch (e) {
      print('Error loading credentials: $e');
    } finally {
      _loadPendingContent();
    }
  }

  Future<void> _loadPendingContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pending-info/'),
        headers: {
          'Content-Type': 'application/json',
          'X-Admin-Email': _adminEmail,
          'X-Admin-Password': _adminPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingContent = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load pending info: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading content: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveContent(int contentId) async {
    print('=== APPROVE CONTENT FUNCTION CALLED ===');
    print('Content ID: $contentId');
    print('Admin Email: $_adminEmail');
    print('Admin Password length: ${_adminPassword.length}');
    print('Admin Password: ${_adminPassword.isNotEmpty ? '***' : 'EMPTY'}');

    setState(() {
      _isLoading = true;
    });

    try {
      print('=== APPROVE CONTENT API CALL ===');
      print('URL: http://127.0.0.1:8000/api/approve-info/$contentId/');
      print('Method: POST');
      print(
        'Headers: {Content-Type: application/json, X-Admin-Email: $_adminEmail, X-Admin-Password: ${_adminPassword.isNotEmpty ? '***' : 'EMPTY'}}',
      );
      print('Body: {"email":"$_adminEmail","password":"$_adminPassword"}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/approve-info/$contentId/'),
        headers: {
          'Content-Type': 'application/json',
          'X-Admin-Email': _adminEmail,
          'X-Admin-Password': _adminPassword,
        },
        body: jsonEncode({'email': _adminEmail, 'password': _adminPassword}),
      );

      print('=== APPROVE CONTENT RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      print('Content Length: ${response.contentLength} bytes');
      print('Reason Phrase: ${response.reasonPhrase}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('=== APPROVE CONTENT SUCCESS ===');
        print('Response Data: $responseData');
        print('Message: ${responseData['message']}');
        print('Pending Info: ${responseData['pending_info']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Content approved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadPendingContent();
      } else {
        print('=== APPROVE CONTENT FAILED ===');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve content'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('=== APPROVE CONTENT ERROR ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving content: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitInfo(
    String heading,
    String description,
    String? imagePath,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/submit-info/'),
        headers: {
          'Content-Type': 'application/json',
          'X-Admin-Email': _adminEmail,
          'X-Admin-Password': _adminPassword,
        },
        body: jsonEncode({
          'email': _adminEmail,
          'password': _adminPassword,
          'heading': heading,
          'description': description,
          'image': imagePath ?? '', // Would be base64 encoded image
        }),
      );

      // Log the API call details exactly as requested
      print('Environment');
      print('POST');
      print('http://127.0.0.1:8000/api/submit-info/');
      print(
        jsonEncode({
          'email': _adminEmail,
          'password': _adminPassword,
          'heading': heading,
          'description': description,
        }),
      );
      print('1');
      print(
        jsonEncode({
          'email': _adminEmail,
          'password': _adminPassword,
          'heading': heading,
          'description': description,
        }),
      );
      print(response.statusCode);
      print(response.reasonPhrase);
      print('${response.contentLength} ms');
      print('${response.body.length} KB');
      print(response.body);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Information submitted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the pending content list
        await _loadPendingContent();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit information'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting information: ${e.toString()}'),
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
        title: const Text('Content Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingContent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingContent.isEmpty
          ? const Center(
              child: Text(
                'No pending content',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPendingContent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingContent.length,
                itemBuilder: (context, index) {
                  final content = _pendingContent[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content info
                          Row(
                            children: [
                              const Icon(Icons.article, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  content['heading'] ?? 'No Heading',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content['description'] ??
                                'No description available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _approveContent(content['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Approve Content',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Show more details
                                    _showContentDetails(content);
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

  void _showContentDetails(Map<String, dynamic> content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heading: ${content['heading'] ?? 'No Heading'}'),
            Text('Description: ${content['description'] ?? 'No description'}'),
            Text('Status: ${content['status'] ?? 'Unknown'}'),
            Text('Content ID: ${content['id'] ?? 'Unknown'}'),
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
