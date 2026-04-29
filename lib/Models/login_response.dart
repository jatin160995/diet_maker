import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/user_profile.dart';

class LoginResponse {
  final UserProfile profile;
  final DietaryPreference dietaryPreference;
  final String accessToken;

  LoginResponse({
    required this.profile,
    required this.dietaryPreference,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      profile: UserProfile.fromJson(json['profile']),
      dietaryPreference: DietaryPreference.fromJson(json['dietary_preference']),
      accessToken: json['access_token'] ?? '',
    );
  }
}
