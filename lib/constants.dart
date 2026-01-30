import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get apiUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  // API endpoints
  static String get loginEndpoint => '$apiUrl/api/login/';
  static String get registerEndpoint => '$apiUrl/api/register/';
  static String get profileEndpoint => '$apiUrl/api/profile/';
  static String get activeInfoEndpoint => '$apiUrl/api/active-info/';
  static String get pendingUsersEndpoint => '$apiUrl/api/pending-users/';
  static String get approveUserEndpoint => '$apiUrl/api/approve-user/';
  static String get approveInfoEndpoint => '$apiUrl/api/approve-info/';
  static String get pendingInfoEndpoint => '$apiUrl/api/pending-info/';
  static String get submitInfoEndpoint => '$apiUrl/api/submit-info/';

  // Image base URL
  static String get imageBaseUrl => apiUrl;
}
