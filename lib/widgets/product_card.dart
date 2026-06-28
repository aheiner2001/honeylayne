import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../theme/honey_theme.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  Future<void> _open() async {
    final url = widget.product.instagramUrl;
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: HoneyColors.pink.withValues(alpha: _hover ? 0.28 : 0.14),
                blurRadius: _hover ? 22 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 0.82,
                child: ProductImage(imageUrl: p.imageUrl, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HoneyTheme.serif(
                                  size: 17, color: HoneyColors.pinkDeep)),
                          const SizedBox(height: 3),
                          Text('\$${p.price.toStringAsFixed(2)}',
                              style: HoneyTheme.sans(
                                  size: 13, color: HoneyColors.textSoft)),
                        ],
                      ),
                    ),
                    Icon(Icons.favorite_border,
                        size: 18, color: HoneyColors.pink),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
