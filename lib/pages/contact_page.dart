import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/store.dart';
import '../models/site_settings.dart';
import '../theme/honey_theme.dart';
import '../widgets/footer.dart';
import '../widgets/site_header.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HoneyStore>().settings;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      backgroundColor: HoneyColors.blush,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SiteHeader(active: 'Contact'),
            if (s.sectionOn('contact.details'))
              _ContactSection(settings: s, compact: compact),
            const SizedBox(height: 36),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final SiteSettings settings;
  final bool compact;
  const _ContactSection({required this.settings, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 24, vertical: compact ? 40 : 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Text(settings.contactTitle,
                  textAlign: TextAlign.center,
                  style: HoneyTheme.script(size: compact ? 46 : 60)),
              const SizedBox(height: 14),
              Text(settings.contactBlurb,
                  textAlign: TextAlign.center,
                  style: HoneyTheme.serif(
                      size: 18,
                      color: HoneyColors.text,
                      weight: FontWeight.w500)),
              const SizedBox(height: 28),
              if (settings.contactEmail.isNotEmpty)
                _ContactRow(
                  icon: Icons.mail_outline,
                  label: settings.contactEmail,
                  onTap: () => _open('mailto:${settings.contactEmail}'),
                ),
              if (settings.contactInstagram.isNotEmpty)
                _ContactRow(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  onTap: () => _open(settings.contactInstagram),
                ),
              if (settings.contactPhone.isNotEmpty)
                _ContactRow(
                  icon: Icons.phone_outlined,
                  label: settings.contactPhone,
                  onTap: () => _open('tel:${settings.contactPhone}'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: HoneyColors.pink, size: 20),
                const SizedBox(width: 12),
                Text(label,
                    style: HoneyTheme.serif(
                        size: 17,
                        color: HoneyColors.pinkDeep,
                        weight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
