import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/site_settings.dart';

/// Storage abstraction so the app can run locally today and switch to
/// Firebase once credentials are configured (see README + firebase_config.dart).
abstract class HoneyBackend {
  /// Returns null when nothing has been saved yet (use seed/defaults).
  Future<List<Product>?> loadProducts();
  Future<SiteSettings?> loadSettings();
  Future<void> saveProducts(List<Product> products);
  Future<void> saveSettings(SiteSettings settings);

  /// Persists an uploaded image and returns a value usable by [Image]:
  /// a data URI (local) or an https download URL (Firebase Storage).
  Future<String> uploadImage(Uint8List bytes, String productId);
}

/// Stores everything in the browser via shared_preferences. Images are kept
/// inline as base64 data URIs. Great for a quick start; data lives on this
/// device/browser only.
class LocalBackend implements HoneyBackend {
  @override
  Future<List<Product>?> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('hl_products');
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SiteSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('hl_settings');
    if (raw == null) return null;
    try {
      return SiteSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'hl_products', jsonEncode(products.map((p) => p.toJson()).toList()));
  }

  @override
  Future<void> saveSettings(SiteSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hl_settings', jsonEncode(settings.toJson()));
  }

  @override
  Future<String> uploadImage(Uint8List bytes, String productId) async {
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
