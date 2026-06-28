import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../theme/honey_theme.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final visible = context.watch<HoneyStore>().settings.visibleNav;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    final shopLinks = [
      for (final c in ['Dresses', 'Tops', 'Bottoms', 'Accessories'])
        if (visible.contains(c)) c,
      'Shop All',
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
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 32,
            spacing: 48,
            children: [
              _FooterCol(title: 'Shop', links: shopLinks),
              const _FooterCol(
                  title: 'Help',
                  links: [
                    'Shipping & Returns',
                    'FAQs',
                    'Size Guide',
                    'Contact Us'
                  ]),
              SizedBox(
                width: 240,
                child: Column(
                  children: [
                    Text('Honey Layne', style: HoneyTheme.logoFont(size: 34)),
                    const SizedBox(height: 8),
                    Text(
                      'Romantic pieces made\nto make you feel beautiful.',
                      textAlign: TextAlign.center,
                      style: HoneyTheme.serif(
                          size: 15,
                          color: HoneyColors.text,
                          weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _Social(Icons.camera_alt_outlined),
                        _Social(Icons.alternate_email),
                        _Social(Icons.favorite_border),
                        _Social(Icons.mail_outline),
                      ],
                    ),
                  ],
                ),
              ),
              const _FooterCol(
                  title: 'About',
                  links: ['Our Story', 'Sustainability', 'Lookbook', 'Careers']),
              const _FooterCol(
                  title: 'Legal',
                  links: [
                    'Terms of Service',
                    'Privacy Policy',
                    'Accessibility'
                  ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterCol({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: HoneyTheme.serif(
                size: 18, color: HoneyColors.pinkDeep, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        for (final l in links)
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

class _Social extends StatelessWidget {
  final IconData icon;
  const _Social(this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, size: 18, color: HoneyColors.pink),
    );
  }
}
