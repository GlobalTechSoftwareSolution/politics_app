import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/politician_model.dart';

class PoliticianService {
  // Fetch MLAs and MPs data for Karnataka only with complete data
  static Future<List<PoliticianModel>> fetchPoliticians() async {
    try {
      // Load data from local JSON file
      final String response = await rootBundle.loadString(
        'assets/karnataka_mlas_updated.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => PoliticianModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching politicians: $e');
      // Return empty list if JSON loading fails
      return [];
    }
  }
}
