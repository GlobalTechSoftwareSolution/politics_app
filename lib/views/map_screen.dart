import 'package:flutter/material.dart';
import 'mla_mp_list_screen.dart';
import '../models/politician_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showKarnatakaInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            backgroundColor: Colors.blue[900],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Karnataka Map'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.map, size: 80, color: Colors.white38),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Map visualization for Karnataka only
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Simplified map visualization of Karnataka
                        Positioned(
                          top: 30,
                          left: 20,
                          right: 20,
                          bottom: 30,
                          child: CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: KarnatakaMapPainter(),
                          ),
                        ),

                        // Major cities in Karnataka
                        Positioned(
                          top: 80,
                          left: 100,
                          child: _buildCityMarker('Bengaluru'),
                        ),
                        Positioned(
                          top: 150,
                          right: 120,
                          child: _buildCityMarker('Mysuru'),
                        ),
                        Positioned(
                          bottom: 120,
                          left: 80,
                          child: _buildCityMarker('Mangaluru'),
                        ),
                        Positioned(
                          bottom: 150,
                          right: 100,
                          child: _buildCityMarker('Hubballi'),
                        ),
                        Positioned(
                          top: 120,
                          left: 180,
                          child: _buildCityMarker('Belagavi'),
                        ),
                        Positioned(
                          bottom: 100,
                          left: 150,
                          child: _buildCityMarker('Davangere'),
                        ),

                        // Info panel when Karnataka is selected
                        if (_showKarnatakaInfo)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Karnataka',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Explore MLAs & MPs',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MlaMpListScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Politicians',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showKarnatakaInfo = false;
                                      });
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info about Karnataka politicians
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Karnataka Political Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Karnataka has 224 MLAs in the Legislative Assembly and 28 MPs in the Parliament.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard('MLAs', '224'),
                              _buildInfoCard('MPs', '28'),
                              _buildInfoCard('Parties', '5+'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MlaMpListScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'View All Politicians',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityMarker(String cityName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showKarnatakaInfo = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Custom painter for Karnataka map shape
class KarnatakaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[200]!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw a simplified shape of Karnataka
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width * 0.9, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.9);
    path.lineTo(size.width * 0.1, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
