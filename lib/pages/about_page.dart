import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/site_settings.dart';
import '../theme/honey_theme.dart';
import '../widgets/footer.dart';
import '../widgets/product_image.dart';
import '../widgets/site_header.dart';

/// Maps a feature icon key to a Material icon.
IconData featureIcon(String key) {
  switch (key) {
    case 'leaf':
      return Icons.spa_outlined;
    case 'flower':
      return Icons.local_florist_outlined;
    case 'bag':
      return Icons.shopping_bag_outlined;
    case 'star':
      return Icons.star_border;
    case 'sparkle':
      return Icons.auto_awesome_outlined;
    case 'heart':
    default:
      return Icons.favorite_border;
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HoneyStore>().settings;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 820;

    return Scaffold(
      backgroundColor: HoneyColors.blush,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SiteHeader(active: 'About'),
            if (s.sectionOn('about.story'))
              _StorySection(settings: s, compact: compact),
            if (s.sectionOn('about.features'))
              _FeatureBand(features: s.aboutFeatures, compact: compact),
            const SizedBox(height: 36),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  final SiteSettings settings;
  final bool compact;
  const _StorySection({required this.settings, required this.compact});

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(settings.aboutTitle,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.script(size: compact ? 46 : 58)),
        const SizedBox(height: 18),
        Text(settings.aboutBody1,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.serif(
                size: 18, color: HoneyColors.text, weight: FontWeight.w500)),
        const SizedBox(height: 14),
        Text(settings.aboutBody2,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.serif(
                size: 18, color: HoneyColors.text, weight: FontWeight.w500)),
        const SizedBox(height: 18),
        Text(settings.aboutThankYou,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: HoneyTheme.script(size: compact ? 30 : 34)),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 80, vertical: compact ? 36 : 56),
      child: compact
          ? Column(children: [
              text,
              const SizedBox(height: 32),
              _StoryPhoto(imageUrl: settings.aboutImageUrl),
            ])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: text),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: _StoryPhoto(imageUrl: settings.aboutImageUrl)),
              ],
            ),
    );
  }
}

class _StoryPhoto extends StatelessWidget {
  final String imageUrl;
  const _StoryPhoto({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 0.03,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: ProductImage(imageUrl: imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Positioned(
          top: -12,
          child: Transform.rotate(
            angle: -0.04,
            child: Container(
                width: 96,
                height: 26,
                color: HoneyColors.pinkSoft.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }
}

class _FeatureBand extends StatelessWidget {
  final List<FeatureItem> features;
  final bool compact;
  const _FeatureBand({required this.features, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HoneyColors.blushDeep,
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 80, vertical: compact ? 36 : 48),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 28,
        runSpacing: 28,
        children: [
          for (final f in features)
            SizedBox(
              width: compact ? 140 : 200,
              child: Column(
                children: [
                  Icon(featureIcon(f.icon), color: HoneyColors.pinkDeep, size: 34),
                  const SizedBox(height: 14),
                  Text(f.text,
                      textAlign: TextAlign.center,
                      style: HoneyTheme.serif(
                          size: 16,
                          color: HoneyColors.text,
                          weight: FontWeight.w500)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
