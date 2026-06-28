import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/site_settings.dart';
import 'backend.dart';
import 'seed.dart';

/// App-wide state: catalog, site settings, manager auth. Reads/writes go
/// through a [HoneyBackend] (local browser storage or Firebase).
class HoneyStore extends ChangeNotifier {
  HoneyStore(this._backend, {this.authEnabled = false});

  final HoneyBackend _backend;

  /// True when Firebase is configured. The studio is gated by the access code;
  /// when Firebase is on we also sign in anonymously so Firestore/Storage writes
  /// are permitted by the security rules.
  final bool authEnabled;

  List<Product> _products = List.of(seedProducts);
  SiteSettings _settings = SiteSettings.initial();
  bool _managerUnlocked = false;
  bool _loaded = false;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.favorite).toList();
  SiteSettings get settings => _settings;
  bool get loaded => _loaded;

  /// True once the correct access code has been entered — the studio is open.
  bool get managerUnlocked => _managerUnlocked;

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

  /// Open the studio with the access code. When Firebase is configured we also
  /// sign in anonymously so the security rules allow saving content. Returns
  /// true on success, false if the code is wrong.
  Future<bool> unlock(String password) async {
    if (!checkManagerPassword(password)) return false;
    if (authEnabled) {
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (_) {
        // Anonymous auth may not be enabled yet — the studio still opens so
        // copy can be edited, but Firestore/Storage writes will be rejected
        // until "Anonymous" sign-in is turned on in the Firebase console.
      }
    }
    _managerUnlocked = true;
    notifyListeners();
    return true;
  }

  void lock() {
    _managerUnlocked = false;
    if (authEnabled) {
      try {
        FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    notifyListeners();
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
