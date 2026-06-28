import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../theme/honey_theme.dart';
import '../widgets/footer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../widgets/site_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HoneyStore>();
    final settings = store.settings;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      backgroundColor: HoneyColors.blush,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SiteHeader(active: 'Home'),
            if (settings.sectionOn('home.hero'))
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 14 : 28, vertical: compact ? 16 : 22),
                child: _Hero(
                  line1: settings.heroTitleLine1,
                  line2: settings.heroTitleLine2,
                  subtitle: settings.heroSubtitle,
                  buttonLabel: settings.heroButtonLabel,
                  imageUrl: settings.heroImageUrl,
                  compact: compact,
                ),
              ),
            if (settings.sectionOn('home.favorites'))
              _FavoritesSection(
                  compact: compact, title: settings.favoritesTitle),
            const SizedBox(height: 36),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String line1;
  final String line2;
  final String subtitle;
  final String buttonLabel;
  final String imageUrl;
  final bool compact;
  const _Hero({
    required this.line1,
    required this.line2,
    required this.subtitle,
    required this.buttonLabel,
    required this.imageUrl,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(line1,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.script(size: compact ? 44 : 64)),
        Text(line2,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.script(size: compact ? 44 : 64)),
        const SizedBox(height: 14),
        SizedBox(
          width: 360,
          child: Text(subtitle,
              textAlign: compact ? TextAlign.center : TextAlign.left,
              style: HoneyTheme.serif(
                  size: 17,
                  color: HoneyColors.text,
                  weight: FontWeight.w500)),
        ),
        const SizedBox(height: 24),
        _ShopNowButton(label: buttonLabel),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: HoneyColors.heroPanel,
        child: Stack(
          children: [
            // Floral accent in the bottom-left corner.
            Positioned(
              left: -30,
              bottom: -40,
              child: IgnorePointer(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159)..rotateZ(-0.15),
                  child: Image.asset('assets/images/floral_topright.png',
                      width: compact ? 150 : 210, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 24 : 56, vertical: compact ? 28 : 38),
              child: compact
                  ? Column(children: [
                      text,
                      const SizedBox(height: 28),
                      _Polaroid(imageUrl: imageUrl),
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Center(child: text)),
                        const SizedBox(width: 24),
                        _Polaroid(imageUrl: imageUrl),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopNowButton extends StatefulWidget {
  final String label;
  const _ShopNowButton({required this.label});
  @override
  State<_ShopNowButton> createState() => _ShopNowButtonState();
}

class _ShopNowButtonState extends State<_ShopNowButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/shop'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 15),
          decoration: BoxDecoration(
            color: _hover ? HoneyColors.pinkDeep : HoneyColors.pink,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: HoneyColors.pink.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(widget.label,
              style: HoneyTheme.sans(
                  size: 13,
                  color: Colors.white,
                  weight: FontWeight.w600,
                  spacing: 1.5)),
        ),
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  final String imageUrl;
  const _Polaroid({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final w = compact ? 220.0 : 250.0;
    return SizedBox(
      width: w + 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.03,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: w,
                  height: w * 0.92,
                  child: ProductImage(imageUrl: imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          // Tape.
          Positioned(
            top: -10,
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 86,
                height: 24,
                color: HoneyColors.pinkSoft.withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: -6,
            child: Icon(Icons.favorite_border,
                color: HoneyColors.pinkDeep, size: 22),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  final bool compact;
  final String title;
  const _FavoritesSection({required this.compact, required this.title});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<HoneyStore>().favorites;
    final width = MediaQuery.sizeOf(context).width;
    int columns;
    if (width >= 980) {
      columns = 5;
    } else if (width >= 760) {
      columns = 4;
    } else if (width >= 520) {
      columns = 3;
    } else {
      columns = 2;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_border,
                  size: 18, color: HoneyColors.pink),
              const SizedBox(width: 8),
              Text(title,
                  style: HoneyTheme.serif(
                      size: 24,
                      color: HoneyColors.pinkDeep,
                      weight: FontWeight.w600)),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go('/shop'),
                  child: Row(
                    children: [
                      Text('View all',
                          style: HoneyTheme.sans(
                              size: 13, color: HoneyColors.pink)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 14, color: HoneyColors.pink),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) => ProductCard(product: favorites[i]),
          ),
        ],
      ),
    );
  }
}
