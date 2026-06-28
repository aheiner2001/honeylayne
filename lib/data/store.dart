import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/site_settings.dart';
import 'backend.dart';
import 'seed.dart';

/// Manager password. Injected at build time from `--dart-define-from-file=.env`
/// (locally) or the MANAGER_PASSWORD GitHub Secret (in CI), so the real password
/// never lives in source. The default is only a placeholder for dev builds that
/// forget to pass it.
const kManagerPassword =
    String.fromEnvironment('MANAGER_PASSWORD', defaultValue: 'changeme');

/// App-wide state: catalog, site settings, manager auth. Reads/writes go
/// through a [HoneyBackend] (local browser storage or Firebase).
class HoneyStore extends ChangeNotifier {
  HoneyStore(this._backend);

  final HoneyBackend _backend;

  List<Product> _products = List.of(seedProducts);
  SiteSettings _settings = SiteSettings.initial();
  bool _managerUnlocked = false;
  bool _loaded = false;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.favorite).toList();
  SiteSettings get settings => _settings;
  bool get managerUnlocked => _managerUnlocked;
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
  bool unlock(String password) {
    // Reject empty passwords so a missing MANAGER_PASSWORD can never unlock.
    if (kManagerPassword.isNotEmpty && password == kManagerPassword) {
      _managerUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lock() {
    _managerUnlocked = false;
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
