import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/store.dart';
import '../models/site_settings.dart';
import '../theme/honey_theme.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HoneyStore>().settings;
    if (!settings.sectionOn('footer')) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final columns = settings.footerColumns;
    final mid = (columns.length / 2).ceil();

    final brand = SizedBox(
      width: 240,
      child: Column(
        children: [
          Text('Honey Layne', style: HoneyTheme.logoFont(size: 34)),
          const SizedBox(height: 8),
          Text(settings.footerTagline,
              textAlign: TextAlign.center,
              style: HoneyTheme.serif(
                  size: 15, color: HoneyColors.text, weight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Social(Icons.camera_alt_outlined,
                  onTap: () => _open(settings.contactInstagram)),
              const _Social(Icons.alternate_email),
              const _Social(Icons.favorite_border),
              _Social(Icons.mail_outline,
                  onTap: settings.contactEmail.isEmpty
                      ? null
                      : () => _open('mailto:${settings.contactEmail}')),
            ],
          ),
        ],
      ),
    );

    // Brand block sits in the middle, columns split to either side.
    final children = <Widget>[
      for (final c in columns.take(mid)) _FooterCol(column: c),
      brand,
      for (final c in columns.skip(mid)) _FooterCol(column: c),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HoneyColors.cream, Color(0xFFF7E7C9)],
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 80, vertical: compact ? 36 : 52),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 32,
        spacing: 48,
        children: children,
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final FooterColumn column;
  const _FooterCol({required this.column});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(column.title,
            style: HoneyTheme.serif(
                size: 18, color: HoneyColors.pinkDeep, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        for (final l in column.links)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(l,
                style: HoneyTheme.sans(
                    size: 13, color: HoneyColors.text, weight: FontWeight.w400)),
          ),
      ],
    );
  }
}

Future<void> _open(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.platformDefault);
}

class _Social extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Social(this.icon, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, size: 18, color: HoneyColors.pink),
    );
    if (onTap == null) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}
