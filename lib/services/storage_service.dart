import 'dart:convert';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'access_token';
  static const String _profileKey = 'user_profile';
  static const String _dietPrefKey = 'dietary_preference';

  /// Save login response
  static Future<void> saveLoginData(LoginResponse login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, login.accessToken);
    await prefs.setString(_profileKey, jsonEncode(login.profile));
    await prefs.setString(_dietPrefKey, jsonEncode(login.dietaryPreference));
  }

  /// Retrieve login data
  static Future<LoginResponse?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final profile = prefs.getString(_profileKey);
    final dietPref = prefs.getString(_dietPrefKey);

    if (token != null && profile != null && dietPref != null) {
      return LoginResponse(
        accessToken: token,
        profile: UserProfile.fromJson(jsonDecode(profile)),
        dietaryPreference: DietaryPreference.fromJson(jsonDecode(dietPref)),
      );
    }
    return null;
  }

  /// Clear login/session data
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_dietPrefKey);
  }

  /// Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  /// Get only token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
