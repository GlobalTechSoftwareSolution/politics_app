import 'package:flutter/material.dart';
import 'politician_detail_screen.dart';
import '../models/politician_model.dart';
import '../services/politician_service.dart';

class MlaMpListScreen extends StatefulWidget {
  const MlaMpListScreen({super.key});

  @override
  State<MlaMpListScreen> createState() => _MlaMpListScreenState();
}

class _MlaMpListScreenState extends State<MlaMpListScreen> {
  List<PoliticianModel> _politicians = [];
  List<PoliticianModel> _filteredPoliticians = [];
  bool _isLoading = true;
  String _selectedPosition = 'All Positions';

  final List<String> _positions = ['All Positions', 'MLA', 'MP'];

  @override
  void initState() {
    super.initState();
    _fetchPoliticians();
  }

  // Fetch politicians
  void _fetchPoliticians() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final politicians = await PoliticianService.fetchPoliticians();

      setState(() {
        _politicians = politicians;
        _filteredPoliticians = politicians;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching politicians: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load politicians')),
      );
    }
  }

  // Filter politicians based on selected position
  void _filterPoliticians() {
    List<PoliticianModel> filtered = _politicians;

    if (_selectedPosition != 'All Positions') {
      filtered = filtered
          .where((p) => p.position == _selectedPosition)
          .toList();
    }

    setState(() {
      _filteredPoliticians = filtered;
    });
  }

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
              title: const Text('Karnataka MLAs & MPs'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.people, size: 80, color: Colors.white38),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_politicians.where((p) => p.position == "MLA").length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'MLAs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_politicians.where((p) => p.position == "MP").length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'MPs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filter section - only position filter
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPosition,
                        items: _positions.map((String position) {
                          return DropdownMenuItem<String>(
                            value: position,
                            child: Text(position),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPosition = newValue!;
                            _filterPoliticians();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Loading indicator or politician list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final politician = _filteredPoliticians[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue[900],
                        ),
                      ),
                      title: Text(
                        politician.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            politician.position,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${politician.constituency}, ${politician.state}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              politician.party,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            politician.experience,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PoliticianDetailScreen(politician: politician),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }, childCount: _filteredPoliticians.length),
            ),
        ],
      ),
    );
  }
}
