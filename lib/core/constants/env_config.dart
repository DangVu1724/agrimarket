import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Firebase Configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  // GitHub Configuration
  static String get githubToken => dotenv.env['GITHUB_TOKEN'] ?? '';

  static String get githubOwner => dotenv.env['GITHUB_OWNER'] ?? '';

  static String get githubRepo => dotenv.env['GITHUB_REPO'] ?? '';

  // Google Maps
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Security
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? 'default_key_32_chars_long_here';

  // Validation
  static bool get isConfigValid {
    return firebaseProjectId.isNotEmpty &&
        firebaseApiKey.isNotEmpty &&
        githubToken.isNotEmpty &&
        githubOwner.isNotEmpty &&
        githubRepo.isNotEmpty;
  }
}
