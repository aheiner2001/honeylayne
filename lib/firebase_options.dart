import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for Honey Layne (project: honeylayne-8ef16).
///
/// These web config values are not secret — Google designs them to be public.
/// Security is enforced by Firestore/Storage rules (see firestore.rules +
/// storage.rules). This app is web-only, so [currentPlatform] returns [web].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDGo-9V6RsJJnZWi0IEYofjlLJvXeFCTnA',
    appId: '1:135157209514:web:ef845aaee6de609da7b3d3',
    messagingSenderId: '135157209514',
    projectId: 'honeylayne-8ef16',
    authDomain: 'honeylayne-8ef16.firebaseapp.com',
    storageBucket: 'honeylayne-8ef16.firebasestorage.app',
  );
}
