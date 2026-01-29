import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/login_screen.dart';
import '../views/dashboard_screen.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user credentials to local storage
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_isLoggedInKey, true);
    print('=== CREDENTIALS SAVED ===');
    print('Email: $email');
    print('Password length: ${password.length}');
  }

  // Get saved credentials from local storage
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) {
      print('=== NO SAVED CREDENTIALS (NOT LOGGED IN) ===');
      return null;
    }

    final email = prefs.getString(_emailKey);
    final password = prefs.getString(_passwordKey);

    if (email == null || password == null) {
      print('=== NO SAVED CREDENTIALS (NULL VALUES) ===');
      return null;
    }

    print('=== RETRIEVING SAVED CREDENTIALS ===');
    print('Email: $email');
    print('Password length: ${password.length}');

    return {'email': email, 'password': password};
  }

  // Clear saved credentials (logout)
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.setBool(_isLoggedInKey, false);
    print('=== CREDENTIALS CLEARED ===');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    print('=== LOGIN STATUS CHECK ===');
    print('Is logged in: $isLoggedIn');
    return isLoggedIn;
  }
}

// Global auth service instance
AuthService authService = AuthService();
