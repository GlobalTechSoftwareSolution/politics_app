import 'package:flutter/material.dart';
import '../models/politician_model.dart';

class PoliticianDetailScreen extends StatelessWidget {
  final PoliticianModel politician;

  const PoliticianDetailScreen({super.key, required this.politician});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                  _sharePolitician(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(politician.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.account_balance,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Profile content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            politician.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            politician.position,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.location_on,
                            'Constituency',
                            '${politician.constituency}, ${politician.state}',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.group, 'Party', politician.party),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.work,
                            'Experience',
                            politician.experience,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.school,
                            'Education',
                            politician.education,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Options
                  const Text(
                    'Contact Options',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildContactOption(Icons.email, 'Send Email', Colors.blue),
                  const SizedBox(height: 12),
                  _buildContactOption(Icons.phone, 'Call Office', Colors.green),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    Icons.location_on,
                    'Visit Constituency Office',
                    Colors.orange,
                  ),

                  const SizedBox(height: 30),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle follow
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Follow',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle share
                            _sharePolitician(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue[900]!),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[900], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption(IconData icon, String text, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(text, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle contact option
        },
      ),
    );
  }

  // Share politician functionality
  void _sharePolitician(BuildContext context) {
    final String shareText =
        'Check out ${politician.name}, ${politician.position} from ${politician.constituency}, ${politician.state}.\n'
        'Party: ${politician.party}\n'
        'Experience: ${politician.experience}\n'
        'Education: ${politician.education}\n\n'
        'Source: Politics App';

    // Show snackbar confirming share action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing information about ${politician.name}...'),
        backgroundColor: Colors.blue[900],
      ),
    );
  }
}
