import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/product.dart';
import '../theme/honey_theme.dart';
import '../widgets/footer.dart';
import '../widgets/product_card.dart';
import '../widgets/site_header.dart';

class ShopPage extends StatelessWidget {
  /// null => Shop All. Otherwise a category name (Dresses, Tops, ...).
  final String? category;
  const ShopPage({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HoneyStore>();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    final List<Product> items = category == null
        ? store.products
        : store.byCategory(category!);
    final title = category ?? 'Shop All';
    final active = category ?? 'Shop All';

    int columns;
    if (width >= 980) {
      columns = 4;
    } else if (width >= 760) {
      columns = 3;
    } else if (width >= 520) {
      columns = 2;
    } else {
      columns = 2;
    }

    return Scaffold(
      backgroundColor: HoneyColors.blush,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SiteHeader(active: active),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  compact ? 16 : 40, compact ? 28 : 44, compact ? 16 : 40, 8),
              child: Column(
                children: [
                  Text(title, style: HoneyTheme.script(size: compact ? 44 : 56)),
                  const SizedBox(height: 6),
                  Text('${items.length} piece${items.length == 1 ? '' : 's'}',
                      style: HoneyTheme.sans(
                          size: 13, color: HoneyColors.textSoft)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 14 : 40, vertical: 16),
              child: items.isEmpty
                  ? _EmptyState(compact: compact)
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (_, i) => ProductCard(product: items[i]),
                    ),
            ),
            const SizedBox(height: 36),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool compact;
  const _EmptyState({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.local_florist_outlined,
              color: HoneyColors.pinkSoft, size: 48),
          const SizedBox(height: 14),
          Text('New pieces coming soon',
              style: HoneyTheme.serif(
                  size: 20, color: HoneyColors.pinkDeep)),
        ],
      ),
    );
  }
}
