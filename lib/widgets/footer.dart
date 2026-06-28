import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                  onTap: settings.contactInstagram.isEmpty
                      ? null
                      : () => _open(settings.contactInstagram)),
              _Social(Icons.alternate_email,
                  onTap: settings.contactEmail.isEmpty
                      ? null
                      : () => _open('mailto:${settings.contactEmail}')),
              _Social(Icons.favorite_border, onTap: () => context.go('/shop')),
              _Social(Icons.mail_outline, onTap: () => context.go('/contact')),
            ],
          ),
        ],
      ),
    );

    final decoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [HoneyColors.cream, Color(0xFFF7E7C9)],
      ),
    );

    // On mobile: stack everything centered (brand on top, columns below).
    if (compact) {
      return Container(
        width: double.infinity,
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            brand,
            const SizedBox(height: 36),
            for (final c in columns)
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: _FooterCol(column: c, center: true),
              ),
          ],
        ),
      );
    }

    // On desktop: brand in the middle, columns split to either side.
    final children = <Widget>[
      for (final c in columns.take(mid)) _FooterCol(column: c),
      brand,
      for (final c in columns.skip(mid)) _FooterCol(column: c),
    ];

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 52),
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
  final bool center;
  const _FooterCol({required this.column, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(column.title,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HoneyTheme.serif(
                size: 18, color: HoneyColors.pinkDeep, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        for (final l in column.links)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: _FooterLinkText(link: l, center: center),
          ),
      ],
    );
  }
}

class _FooterLinkText extends StatefulWidget {
  final FooterLink link;
  final bool center;
  const _FooterLinkText({required this.link, this.center = false});
  @override
  State<_FooterLinkText> createState() => _FooterLinkTextState();
}

class _FooterLinkTextState extends State<_FooterLinkText> {
  bool _hover = false;

  void _go() {
    final url = widget.link.url;
    if (url.isEmpty) return;
    if (url.startsWith('/')) {
      context.go(url);
    } else {
      _open(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = widget.link.url.isNotEmpty;
    final text = Text(
      widget.link.label,
      textAlign: widget.center ? TextAlign.center : TextAlign.start,
      style: HoneyTheme.sans(
        size: 13,
        color: hasLink && _hover ? HoneyColors.pinkDeep : HoneyColors.text,
        weight: FontWeight.w400,
      ),
    );
    if (!hasLink) return text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: _go, child: text),
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
