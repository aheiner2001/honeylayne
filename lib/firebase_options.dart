import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for Honey Layne. Values are injected at build time
/// from `--dart-define-from-file=.env` (locally) or GitHub Secrets (in CI),
/// so no real config lives in source. See `.env.example`.
///
/// This app is web-only, so [currentPlatform] returns [web].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  /// Whether real Firebase values were supplied at build time. When false the
  /// app runs on local browser storage instead of trying (and failing) to
  /// connect to Firebase.
  static bool get isConfigured =>
      const String.fromEnvironment('FIREBASE_API_KEY').isNotEmpty;
}
