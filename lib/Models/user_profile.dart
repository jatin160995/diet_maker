class UserProfile {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final String email;
  final String emailVerifiedAt;
  final String phone;
  final String photo;
  final String providerId;
  final String provider;
  final String? socialFacebookId;
  final String? socialGoogleId;
  final String? socialAppleId;
  final String preferredMeasurement;
  final String gender;
  final String timezone;
  final List<String> notification;
  final String membershipStatus;
  final int activeDietaryPreferenceId;
  final String initialSetup;
  final String isActive;
  final String dob;
  final int age;
  final String passwordResetToken;
  final String emailVerificationToken;
  final String createdAt;
  final String updatedAt;
  final String fullName;
  final String photoUrl;
  final String notificationText;
  final List<dynamic> media;

  UserProfile({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerifiedAt,
    required this.phone,
    required this.photo,
    required this.providerId,
    required this.provider,
    required this.socialFacebookId,
    required this.socialGoogleId,
    required this.socialAppleId,
    required this.preferredMeasurement,
    required this.gender,
    required this.timezone,
    required this.notification,
    required this.membershipStatus,
    required this.activeDietaryPreferenceId,
    required this.initialSetup,
    required this.isActive,
    required this.dob,
    required this.age,
    required this.passwordResetToken,
    required this.emailVerificationToken,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.photoUrl,
    required this.notificationText,
    required this.media,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? 0,
    code: json['code'] ?? 0,
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    email: json['email'] ?? '',
    emailVerifiedAt: json['email_verified_at'] ?? '',
    phone: json['phone'] ?? '',
    photo: json['photo'] ?? '',
    providerId: json['provider_id'] ?? '',
    provider: json['provider'] ?? '',
    socialFacebookId: json['social_facebook_id'],
    socialGoogleId: json['social_google_id'],
    socialAppleId: json['social_apple_id'],
    preferredMeasurement: json['preferred_measurement'] ?? '',
    gender: json['gender'] ?? '',
    timezone: json['timezone'] ?? '',
    notification: List<String>.from(json['notification'] ?? []),
    membershipStatus: json['membership_status'] ?? '',
    activeDietaryPreferenceId: json['active_dietary_preference_id'] ?? 0,
    initialSetup: json['initial_setup'] ?? '',
    isActive: json['is_active'] ?? '',
    dob: json['dob'] ?? '',
    age: (double.tryParse(json['age']?.toString() ?? '0') ?? 0).round(),
    passwordResetToken: json['password_reset_token'] ?? '',
    emailVerificationToken: json['email_verification_token'] ?? '',
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    fullName: json['full_name'] ?? '',
    photoUrl: json['photo_url'] ?? '',
    notificationText: json['notification_text'] ?? '',
    media: List<dynamic>.from(json['media'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'email_verified_at': emailVerifiedAt,
    'phone': phone,
    'photo': photo,
    'provider_id': providerId,
    'provider': provider,
    'social_facebook_id': socialFacebookId,
    'social_google_id': socialGoogleId,
    'social_apple_id': socialAppleId,
    'preferred_measurement': preferredMeasurement,
    'gender': gender,
    'timezone': timezone,
    'notification': notification,
    'membership_status': membershipStatus,
    'active_dietary_preference_id': activeDietaryPreferenceId,
    'initial_setup': initialSetup,
    'is_active': isActive,
    'dob': dob,
    'age': age,
    'password_reset_token': passwordResetToken,
    'email_verification_token': emailVerificationToken,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'full_name': fullName,
    'photo_url': photoUrl,
    'notification_text': notificationText,
    'media': media,
  };
}
