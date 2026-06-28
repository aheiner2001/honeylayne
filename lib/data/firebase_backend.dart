import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';
import '../models/site_settings.dart';
import 'backend.dart';

/// Firebase-backed store.
///
/// Firestore layout:
///   products/{productId}        -> product fields
///   site/settings               -> nav toggles + homepage copy
/// Storage layout:
///   products/{productId}.jpg
class FirebaseBackend implements HoneyBackend {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  Future<List<Product>?> loadProducts() async {
    final snap = await _db.collection('products').get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.map((d) => Product.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<SiteSettings?> loadSettings() async {
    final doc = await _db.collection('site').doc('settings').get();
    if (!doc.exists) return null;
    return SiteSettings.fromJson(doc.data()!);
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    final col = _db.collection('products');
    final existing = await col.get();
    final batch = _db.batch();
    // Remove docs no longer present, then upsert the current list.
    final keep = products.map((p) => p.id).toSet();
    for (final d in existing.docs) {
      if (!keep.contains(d.id)) batch.delete(d.reference);
    }
    for (final p in products) {
      batch.set(col.doc(p.id), p.toJson());
    }
    await batch.commit();
  }

  @override
  Future<void> saveSettings(SiteSettings settings) async {
    await _db.collection('site').doc('settings').set(settings.toJson());
  }

  @override
  Future<String> uploadImage(Uint8List bytes, String productId) async {
    final ref = _storage.ref('products/$productId.jpg');
    await ref.putData(
        bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  @override
  Future<String> uploadImagePng(Uint8List bytes, String key) async {
    final ref = _storage.ref('header/$key.png');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    return ref.getDownloadURL();
  }
}
