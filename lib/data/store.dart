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
    String.fromEnvironment('MANAGER_PASSWORD', defaultValue: 'honeybee');

/// App-wide state: catalog, site settings, manager auth. Reads/writes go
/// through a [HoneyBackend] (local browser storage or Firebase).
class HoneyStore extends ChangeNotifier {
  HoneyStore(this._backend, {this.authEnabled = false}) {
    if (authEnabled) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        _signedIn = user != null;
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
  bool _managerUnlocked = false; // local fallback gate (authEnabled == false)
  bool _signedIn = false; // signed in with Google (authEnabled == true)
  String? _managerEmail;
  bool _loaded = false;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.favorite).toList();
  SiteSettings get settings => _settings;
  String? get managerEmail => _managerEmail;
  bool get loaded => _loaded;

  /// Signed in with Google (or unlocked locally when Firebase is off).
  bool get signedIn => authEnabled ? _signedIn : _managerUnlocked;

  /// True once this account is authorized — i.e. the studio should open.
  /// With Firebase, that means signed in AND on the approved list.
  bool get managerUnlocked {
    if (!authEnabled) return _managerUnlocked;
    return _signedIn && isApprovedManager(_managerEmail);
  }

  /// Signed in with Google but this email hasn't entered the access code yet,
  /// so we need to collect it once to authorize the account.
  bool get needsApproval =>
      authEnabled && _signedIn && !isApprovedManager(_managerEmail);

  /// Whether [email] has already been authorized with the access code.
  bool isApprovedManager(String? email) {
    if (email == null) return false;
    final e = email.trim().toLowerCase();
    return _settings.approvedManagerEmails
        .map((m) => m.trim().toLowerCase())
        .contains(e);
  }

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
  /// The access password required to open the studio. Editable from settings;
  /// defaults to 'honeybee'.
  String get managerPassword => _settings.managerPassword.isNotEmpty
      ? _settings.managerPassword
      : 'honeybee';

  /// True if [input] matches the current access password.
  bool checkManagerPassword(String input) =>
      input.trim() == managerPassword;

  /// Change the studio access password and persist it.
  void updateManagerPassword(String password) {
    final trimmed = password.trim();
    if (trimmed.isEmpty) return;
    _settings = _settings.copyWith(managerPassword: trimmed);
    _backend.saveSettings(_settings);
    notifyListeners();
  }

  /// Local fallback gate (used only when [authEnabled] is false).
  bool unlock(String password) {
    if (checkManagerPassword(password)) {
      _managerUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Authorize the currently signed-in Google account by entering the access
  /// code once. On success the email is remembered so future sign-ins skip the
  /// code. Returns null on success, else an error message.
  Future<String?> approveCurrentManager(String code) async {
    if (!checkManagerPassword(code)) {
      return 'Incorrect access code.';
    }
    final email = _managerEmail;
    if (email == null) {
      return 'Sign in with Google first.';
    }
    if (!isApprovedManager(email)) {
      _settings = _settings.copyWith(
        approvedManagerEmails: [..._settings.approvedManagerEmails, email],
      );
      await _backend.saveSettings(_settings);
    }
    notifyListeners();
    return null;
  }

  /// Sign in with Google (popup on web). Returns null on success, else an
  /// error message. The access code is collected once via [approveCurrentManager].
  Future<String?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
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

  /// Upload a PNG (transparency preserved) for header art/icons.
  Future<String> uploadImagePng(Uint8List bytes, String key) =>
      _backend.uploadImagePng(bytes, key);

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
