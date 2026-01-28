import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  static const String _apiKey = 'pub_ce298b90625b4ea5bc022328ddeebced';
  static const String _baseUrl = 'https://newsdata.io/api/1/latest';
  
  // Fetch latest politics news
  static Future<List<NewsModel>> fetchPoliticsNews() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?apikey=$_apiKey&q=politics&country=in'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List newsData = jsonData['results'];
        
        List<NewsModel> newsList = [];
        for (var item in newsData) {
          // Only add news with title and description
          if (item['title'] != null && item['description'] != null) {
            newsList.add(
              NewsModel(
                id: item['article_id'] ?? '',
                title: item['title'] ?? 'No title',
                content: item['description'] ?? 'No description',
                date: item['pubDate'] ?? DateTime.now().toString(),
                imageUrl: item['image_url'] ?? '',
              ),
            );
          }
        }
        
        return newsList;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      // Return sample data if API fails
      return _getSampleNews();
    }
  }
  
  // Get sample news for fallback
  static List<NewsModel> _getSampleNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Government Announces New Healthcare Initiative',
        content: 'The government has unveiled a comprehensive healthcare plan aimed at improving access to medical services in rural areas. The initiative includes funding for new clinics and telemedicine programs.',
        date: '2025-12-01',
        imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      ),
      NewsModel(
        id: '2',
        title: 'Parliament Passes Landmark Education Reform Bill',
        content: 'After months of debate, parliament has approved significant changes to the national education system. The reform focuses on digital learning and vocational training programs.',
        date: '2025-11-28',
        imageUrl: 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      ),
      NewsModel(
        id: '3',
        title: 'Economic Survey Projects Strong Growth for Next Quarter',
        content: 'The annual economic survey indicates robust growth prospects, with GDP expected to expand by 7.5% in the next quarter. Experts attribute this to infrastructure investments and manufacturing growth.',
        date: '2025-11-25',
        imageUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      ),
    ];
  }
}