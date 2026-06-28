import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../theme/honey_theme.dart';

/// Renders a product image from any source the app supports:
/// - asset path ("assets/images/..")
/// - network url ("http..")
/// - inline data uri ("data:image/..;base64,..") from manager uploads
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  const ProductImage({super.key, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _placeholder();

    if (imageUrl.startsWith('data:')) {
      try {
        final base64Part = imageUrl.substring(imageUrl.indexOf(',') + 1);
        final Uint8List bytes = base64Decode(base64Part);
        return Image.memory(bytes, fit: fit, gaplessPlayback: true);
      } catch (_) {
        return _placeholder();
      }
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl,
          fit: fit, errorBuilder: (_, _, _) => _placeholder());
    }
    return Image.asset(imageUrl,
        fit: fit, errorBuilder: (_, _, _) => _placeholder());
  }

  Widget _placeholder() => Container(
        color: HoneyColors.blushDeep,
        alignment: Alignment.center,
        child: const Icon(Icons.local_florist,
            color: HoneyColors.pinkSoft, size: 40),
      );
}
