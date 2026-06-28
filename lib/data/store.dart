import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/site_settings.dart';
import 'backend.dart';
import 'seed.dart';

/// One-time setup code used to register the very first manager account.
/// Injected at build time from `--dart-define-from-file=.env` (locally) or the
/// MANAGER_PASSWORD GitHub Secret (in CI), so it never lives in source. After
/// the manager registers her email, she logs in with email + password and this
/// code is no longer needed for day-to-day access.
const kManagerPassword =
    String.fromEnvironment('MANAGER_PASSWORD', defaultValue: 'changeme');

/// Comma-separated list of Google account emails allowed into the studio.
/// Injected at build time (MANAGER_EMAILS). If empty, any signed-in Google
/// account is allowed — set this in `.env`/Secrets to lock it down.
const kManagerEmails = String.fromEnvironment('MANAGER_EMAILS');

bool _emailAllowed(String? email) {
  final allow = kManagerEmails
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();
  if (allow.isEmpty) return true; // No allowlist configured -> allow any.
  return email != null && allow.contains(email.toLowerCase());
}

/// App-wide state: catalog, site settings, manager auth. Reads/writes go
/// through a [HoneyBackend] (local browser storage or Firebase).
class HoneyStore extends ChangeNotifier {
  HoneyStore(this._backend, {this.authEnabled = false}) {
    if (authEnabled) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        // Only treat the manager as unlocked if their email is allowed.
        _managerUnlocked = user != null && _emailAllowed(user.email);
        _managerEmail = user?.email;
        notifyListeners();
      });
    }
  }

  final HoneyBackend _backend;

  /// True when Firebase is configured, so manager auth uses email/password
  /// accounts. When false (e.g. local dev without Firebase) the studio falls
  /// back to the simple build-time password gate.
  final bool authEnabled;

  List<Product> _products = List.of(seedProducts);
  SiteSettings _settings = SiteSettings.initial();
  bool _managerUnlocked = false;
  String? _managerEmail;
  bool _loaded = false;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.favorite).toList();
  SiteSettings get settings => _settings;
  bool get managerUnlocked => _managerUnlocked;
  String? get managerEmail => _managerEmail;
  bool get loaded => _loaded;

  List<Product> byCategory(String category) =>
      _products.where((p) => p.category == category).toList();

  Future<void> load() async {
    try {
      final p = await _backend.loadProducts();
      final s = await _backend.loadSettings();
      if (p != null && p.isNotEmpty) _products = p;
      if (s != null) _settings = s;
    } catch (_) {
      // Keep seed/defaults on any error.
    }
    _loaded = true;
    notifyListeners();
  }

  // ---- Manager auth ----
  /// Local fallback gate (used only when [authEnabled] is false).
  bool unlock(String password) {
    if (kManagerPassword.isNotEmpty && password == kManagerPassword) {
      _managerUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Sign in with Google (popup on web). Returns null on success, else an
  /// error message. Rejects accounts not on the manager allowlist.
  Future<String?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
      final email = FirebaseAuth.instance.currentUser?.email;
      if (!_emailAllowed(email)) {
        await FirebaseAuth.instance.signOut();
        return 'This Google account isn\'t authorized for the studio.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return null; // User dismissed the popup — not an error.
      }
      return _authMessage(e);
    } catch (e) {
      return 'Could not sign in with Google. Please try again.';
    }
  }

  /// Sign in an existing manager. Returns null on success, else an error
  /// message to show.
  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authMessage(e);
    } catch (e) {
      return 'Could not sign in. Please try again.';
    }
  }

  /// First-time setup: register the manager account, gated by the one-time
  /// setup code. Returns null on success, else an error message.
  Future<String?> registerManager(
      String email, String password, String code) async {
    if (kManagerPassword.isEmpty || code.trim() != kManagerPassword) {
      return 'That setup code is incorrect.';
    }
    if (password.length < 6) {
      return 'Choose a password with at least 6 characters.';
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authMessage(e);
    } catch (e) {
      return 'Could not create the account. Please try again.';
    }
  }

  /// Send a password-reset email. Returns null on success, else a message.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _authMessage(e);
    } catch (e) {
      return 'Could not send the reset email. Please try again.';
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email — just sign in.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase yet.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  void lock() {
    if (authEnabled) {
      FirebaseAuth.instance.signOut();
    } else {
      _managerUnlocked = false;
      notifyListeners();
    }
  }

  // ---- Images ----
  Future<String> uploadProductImage(Uint8List bytes, String productId) =>
      _backend.uploadImage(bytes, productId);

  // ---- Nav / settings ----
  void toggleNav(String label, bool enabled) {
    if (SiteSettings.locked.contains(label)) return;
    final next = Map<String, bool>.from(_settings.navEnabled)..[label] = enabled;
    _settings = _settings.copyWith(navEnabled: next);
    _backend.saveSettings(_settings);
    notifyListeners();
  }

  void toggleSection(String id, bool enabled) {
    final next = Map<String, bool>.from(_settings.sectionVisible)..[id] = enabled;
    _settings = _settings.copyWith(sectionVisible: next);
    _backend.saveSettings(_settings);
    notifyListeners();
  }

  /// Replace the whole settings object (used by the studio's page editors).
  void updateSettings(SiteSettings next) {
    _settings = next;
    _backend.saveSettings(_settings);
    notifyListeners();
  }

  /// Upload any image (hero, about, product) and get back a usable URL/URI.
  Future<String> uploadImage(Uint8List bytes, String key) =>
      _backend.uploadImage(bytes, key);

  // ---- Products ----
  void addProduct(Product p) {
    _products = [..._products, p];
    _backend.saveProducts(_products);
    notifyListeners();
  }

  void updateProduct(Product p) {
    _products = _products.map((e) => e.id == p.id ? p : e).toList();
    _backend.saveProducts(_products);
    notifyListeners();
  }

  void removeProduct(String id) {
    _products = _products.where((e) => e.id != id).toList();
    _backend.saveProducts(_products);
    notifyListeners();
  }
}
