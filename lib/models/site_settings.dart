/// All manager-editable site content: navigation, per-section visibility,
/// page copy, and editable images. Serializes to a single JSON blob.
class SiteSettings {
  // ---- Navigation (top bar) ----
  final Map<String, bool> navEnabled;

  // ---- Per-section show/hide (keyed by ids in [sections]) ----
  final Map<String, bool> sectionVisible;

  // ---- Home / hero ----
  final String heroTitleLine1;
  final String heroTitleLine2;
  final String heroSubtitle;
  final String heroButtonLabel;
  final String heroImageUrl;
  final String favoritesTitle;

  // ---- About / Our Story ----
  final String aboutTitle;
  final String aboutBody1;
  final String aboutBody2;
  final String aboutThankYou;
  final String aboutImageUrl;
  final List<FeatureItem> aboutFeatures;

  // ---- Contact ----
  final String contactTitle;
  final String contactBlurb;
  final String contactEmail;
  final String contactInstagram;
  final String contactPhone;

  // ---- Footer ----
  final String footerTagline;
  final List<FooterColumn> footerColumns;
  final List<SocialLink> footerSocials;

  // ---- Header decorations (manager-uploadable PNGs) ----
  final String headerLeftImageUrl; // bees / top-left
  final String headerRightImageUrl; // florals / top-right
  final String headerShopIconUrl; // shop icon -> Instagram

  // ---- Manager access ----
  /// Password required (in addition to Google sign-in) to open the studio.
  /// Editable from Manager settings. Defaults to 'honeybee'.
  final String managerPassword;

  /// Google emails that have already entered the access code once. They can
  /// sign in afterwards without re-entering it.
  final List<String> approvedManagerEmails;

  // Kept for backwards compatibility with older saved data.
  final String storyText;

  const SiteSettings({
    required this.navEnabled,
    required this.sectionVisible,
    this.heroTitleLine1 = 'Sweet style',
    this.heroTitleLine2 = 'for sunny days',
    this.heroSubtitle = 'Romantic pieces made to make you feel beautiful.',
    this.heroButtonLabel = 'SHOP NOW',
    this.heroImageUrl = 'assets/images/hero_model.png',
    this.favoritesTitle = 'Shop Our Favorites',
    this.aboutTitle = 'Our Story',
    this.aboutBody1 =
        'Honey Layne was created with a love for romantic style, soft details, and the beauty of everyday moments.',
    this.aboutBody2 =
        'We believe that what you wear should make you feel confident, feminine, and like the best version of yourself.',
    this.aboutThankYou = 'Thank you for being here',
    this.aboutImageUrl = 'assets/images/hero_model.png',
    this.aboutFeatures = defaultFeatures,
    this.contactTitle = 'Say Hello',
    this.contactBlurb =
        "We'd love to hear from you — questions, custom requests, or just to say hi.",
    this.contactEmail = 'hello@honeylayne.shop',
    this.contactInstagram = 'https://www.instagram.com/_honeylayne/',
    this.contactPhone = '',
    this.footerTagline = 'Romantic pieces made\nto make you feel beautiful.',
    this.footerColumns = defaultFooterColumns,
    this.footerSocials = defaultSocials,
    this.headerLeftImageUrl = 'assets/images/bees_trail.png',
    this.headerRightImageUrl = 'assets/images/floral_topright.png',
    this.headerShopIconUrl = 'assets/images/shop_icon.png',
    this.managerPassword = 'honeybee',
    this.approvedManagerEmails = const [],
    this.storyText = '',
  });

  static const orderedNav = [
    'Home',
    'Shop All',
    'Dresses',
    'Tops',
    'Bottoms',
    'Accessories',
    'About',
    'Contact',
  ];

  /// Links that cannot be turned off.
  static const locked = {'Home', 'Shop All'};

  /// Toggleable page sections: id -> human label (shown in the studio).
  static const sections = <String, String>{
    'home.hero': 'Home · Hero banner',
    'home.favorites': 'Home · Shop Our Favorites',
    'about.story': 'About · Our Story',
    'about.features': 'About · Feature highlights',
    'contact.details': 'Contact · Details',
    'footer': 'Footer',
  };

  static const defaultFeatures = [
    FeatureItem(icon: 'leaf', text: 'Feminine and timeless designs'),
    FeatureItem(icon: 'heart', text: 'Made to make you feel beautiful inside and out'),
    FeatureItem(icon: 'flower', text: 'Inspired by nature, flowers, and sunny days'),
    FeatureItem(icon: 'bag', text: 'Thoughtful details in every piece'),
  ];

  static const defaultSocials = [
    SocialLink(icon: 'instagram', url: 'https://www.instagram.com/_honeylayne/'),
    SocialLink(icon: 'email', url: 'mailto:hello@honeylayne.shop'),
    SocialLink(icon: 'heart', url: '/shop'),
    SocialLink(icon: 'mail', url: '/contact'),
  ];

  static const defaultFooterColumns = [
    FooterColumn(title: 'Shop', links: [
      FooterLink(label: 'Dresses', url: '/shop/Dresses'),
      FooterLink(label: 'Tops', url: '/shop/Tops'),
      FooterLink(label: 'Bottoms', url: '/shop/Bottoms'),
      FooterLink(label: 'Accessories', url: '/shop/Accessories'),
      FooterLink(label: 'Shop All', url: '/shop'),
    ]),
    FooterColumn(title: 'Help', links: [
      FooterLink(label: 'Contact Us', url: '/contact'),
      FooterLink(label: 'Shipping & Returns'),
      FooterLink(label: 'FAQs'),
      FooterLink(label: 'Size Guide'),
    ]),
    FooterColumn(title: 'About', links: [
      FooterLink(label: 'Our Story', url: '/about'),
      FooterLink(label: 'Sustainability'),
      FooterLink(label: 'Lookbook'),
      FooterLink(label: 'Careers'),
    ]),
    FooterColumn(title: 'Legal', links: [
      FooterLink(label: 'Terms of Service'),
      FooterLink(label: 'Privacy Policy'),
      FooterLink(label: 'Accessibility'),
    ]),
  ];

  factory SiteSettings.initial() => SiteSettings(
        navEnabled: {for (final n in orderedNav) n: true},
        sectionVisible: {for (final s in sections.keys) s: true},
      );

  List<String> get visibleNav =>
      orderedNav.where((n) => navEnabled[n] ?? true).toList();

  bool sectionOn(String id) => sectionVisible[id] ?? true;

  SiteSettings copyWith({
    Map<String, bool>? navEnabled,
    Map<String, bool>? sectionVisible,
    String? heroTitleLine1,
    String? heroTitleLine2,
    String? heroSubtitle,
    String? heroButtonLabel,
    String? heroImageUrl,
    String? favoritesTitle,
    String? aboutTitle,
    String? aboutBody1,
    String? aboutBody2,
    String? aboutThankYou,
    String? aboutImageUrl,
    List<FeatureItem>? aboutFeatures,
    String? contactTitle,
    String? contactBlurb,
    String? contactEmail,
    String? contactInstagram,
    String? contactPhone,
    String? footerTagline,
    List<FooterColumn>? footerColumns,
    List<SocialLink>? footerSocials,
    String? headerLeftImageUrl,
    String? headerRightImageUrl,
    String? headerShopIconUrl,
    String? managerPassword,
    List<String>? approvedManagerEmails,
  }) =>
      SiteSettings(
        navEnabled: navEnabled ?? this.navEnabled,
        sectionVisible: sectionVisible ?? this.sectionVisible,
        heroTitleLine1: heroTitleLine1 ?? this.heroTitleLine1,
        heroTitleLine2: heroTitleLine2 ?? this.heroTitleLine2,
        heroSubtitle: heroSubtitle ?? this.heroSubtitle,
        heroButtonLabel: heroButtonLabel ?? this.heroButtonLabel,
        heroImageUrl: heroImageUrl ?? this.heroImageUrl,
        favoritesTitle: favoritesTitle ?? this.favoritesTitle,
        aboutTitle: aboutTitle ?? this.aboutTitle,
        aboutBody1: aboutBody1 ?? this.aboutBody1,
        aboutBody2: aboutBody2 ?? this.aboutBody2,
        aboutThankYou: aboutThankYou ?? this.aboutThankYou,
        aboutImageUrl: aboutImageUrl ?? this.aboutImageUrl,
        aboutFeatures: aboutFeatures ?? this.aboutFeatures,
        contactTitle: contactTitle ?? this.contactTitle,
        contactBlurb: contactBlurb ?? this.contactBlurb,
        contactEmail: contactEmail ?? this.contactEmail,
        contactInstagram: contactInstagram ?? this.contactInstagram,
        contactPhone: contactPhone ?? this.contactPhone,
        footerTagline: footerTagline ?? this.footerTagline,
        footerColumns: footerColumns ?? this.footerColumns,
        footerSocials: footerSocials ?? this.footerSocials,
        headerLeftImageUrl: headerLeftImageUrl ?? this.headerLeftImageUrl,
        headerRightImageUrl: headerRightImageUrl ?? this.headerRightImageUrl,
        headerShopIconUrl: headerShopIconUrl ?? this.headerShopIconUrl,
        managerPassword: managerPassword ?? this.managerPassword,
        approvedManagerEmails:
            approvedManagerEmails ?? this.approvedManagerEmails,
      );

  Map<String, dynamic> toJson() => {
        'navEnabled': navEnabled,
        'sectionVisible': sectionVisible,
        'heroTitleLine1': heroTitleLine1,
        'heroTitleLine2': heroTitleLine2,
        'heroSubtitle': heroSubtitle,
        'heroButtonLabel': heroButtonLabel,
        'heroImageUrl': heroImageUrl,
        'favoritesTitle': favoritesTitle,
        'aboutTitle': aboutTitle,
        'aboutBody1': aboutBody1,
        'aboutBody2': aboutBody2,
        'aboutThankYou': aboutThankYou,
        'aboutImageUrl': aboutImageUrl,
        'aboutFeatures': aboutFeatures.map((f) => f.toJson()).toList(),
        'contactTitle': contactTitle,
        'contactBlurb': contactBlurb,
        'contactEmail': contactEmail,
        'contactInstagram': contactInstagram,
        'contactPhone': contactPhone,
        'footerTagline': footerTagline,
        'footerColumns': footerColumns.map((c) => c.toJson()).toList(),
        'footerSocials': footerSocials.map((s) => s.toJson()).toList(),
        'headerLeftImageUrl': headerLeftImageUrl,
        'headerRightImageUrl': headerRightImageUrl,
        'headerShopIconUrl': headerShopIconUrl,
        'managerPassword': managerPassword,
        'approvedManagerEmails': approvedManagerEmails,
      };

  factory SiteSettings.fromJson(Map<String, dynamic> j) {
    final nav = (j['navEnabled'] as Map?)?.cast<String, dynamic>() ?? {};
    final sec = (j['sectionVisible'] as Map?)?.cast<String, dynamic>() ?? {};
    final features = (j['aboutFeatures'] as List?)
        ?.map((e) => FeatureItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final cols = (j['footerColumns'] as List?)
        ?.map((e) => FooterColumn.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final socials = (j['footerSocials'] as List?)
        ?.map((e) => SocialLink.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final defaults = SiteSettings.initial();
    return SiteSettings(
      navEnabled: {for (final n in orderedNav) n: (nav[n] as bool?) ?? true},
      sectionVisible: {
        for (final s in sections.keys) s: (sec[s] as bool?) ?? true,
      },
      heroTitleLine1: j['heroTitleLine1'] as String? ?? defaults.heroTitleLine1,
      heroTitleLine2: j['heroTitleLine2'] as String? ?? defaults.heroTitleLine2,
      heroSubtitle: j['heroSubtitle'] as String? ?? defaults.heroSubtitle,
      heroButtonLabel: j['heroButtonLabel'] as String? ?? defaults.heroButtonLabel,
      heroImageUrl: j['heroImageUrl'] as String? ?? defaults.heroImageUrl,
      favoritesTitle: j['favoritesTitle'] as String? ?? defaults.favoritesTitle,
      aboutTitle: j['aboutTitle'] as String? ?? defaults.aboutTitle,
      aboutBody1: j['aboutBody1'] as String? ?? (j['storyText'] as String?) ?? defaults.aboutBody1,
      aboutBody2: j['aboutBody2'] as String? ?? defaults.aboutBody2,
      aboutThankYou: j['aboutThankYou'] as String? ?? defaults.aboutThankYou,
      aboutImageUrl: j['aboutImageUrl'] as String? ?? defaults.aboutImageUrl,
      aboutFeatures: (features == null || features.isEmpty) ? defaultFeatures : features,
      contactTitle: j['contactTitle'] as String? ?? defaults.contactTitle,
      contactBlurb: j['contactBlurb'] as String? ?? defaults.contactBlurb,
      contactEmail: j['contactEmail'] as String? ?? defaults.contactEmail,
      contactInstagram: j['contactInstagram'] as String? ?? defaults.contactInstagram,
      contactPhone: j['contactPhone'] as String? ?? defaults.contactPhone,
      footerTagline: j['footerTagline'] as String? ?? defaults.footerTagline,
      footerColumns: (cols == null || cols.isEmpty) ? defaultFooterColumns : cols,
      footerSocials: socials ?? defaultSocials,
      headerLeftImageUrl: (j['headerLeftImageUrl'] as String?)?.isNotEmpty == true
          ? j['headerLeftImageUrl'] as String
          : defaults.headerLeftImageUrl,
      headerRightImageUrl:
          (j['headerRightImageUrl'] as String?)?.isNotEmpty == true
              ? j['headerRightImageUrl'] as String
              : defaults.headerRightImageUrl,
      headerShopIconUrl: (j['headerShopIconUrl'] as String?)?.isNotEmpty == true
          ? j['headerShopIconUrl'] as String
          : defaults.headerShopIconUrl,
      managerPassword: (j['managerPassword'] as String?)?.isNotEmpty == true
          ? j['managerPassword'] as String
          : defaults.managerPassword,
      approvedManagerEmails: (j['approvedManagerEmails'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class FeatureItem {
  final String icon; // key: leaf | heart | flower | bag | star | sparkle
  final String text;
  const FeatureItem({required this.icon, required this.text});

  FeatureItem copyWith({String? icon, String? text}) =>
      FeatureItem(icon: icon ?? this.icon, text: text ?? this.text);

  Map<String, dynamic> toJson() => {'icon': icon, 'text': text};
  factory FeatureItem.fromJson(Map<String, dynamic> j) =>
      FeatureItem(icon: j['icon'] as String? ?? 'heart', text: j['text'] as String? ?? '');
}

/// A single footer link: a [label] and an optional [url]. The url may be an
/// internal route (e.g. "/shop/Dresses") or an external link
/// (e.g. "https://instagram.com/..."). Empty url = plain, non-clickable text.
class FooterLink {
  final String label;
  final String url;
  const FooterLink({required this.label, this.url = ''});

  FooterLink copyWith({String? label, String? url}) =>
      FooterLink(label: label ?? this.label, url: url ?? this.url);

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
  factory FooterLink.fromJson(Map<String, dynamic> j) =>
      FooterLink(label: j['label'] as String? ?? '', url: j['url'] as String? ?? '');
}

class FooterColumn {
  final String title;
  final List<FooterLink> links;
  const FooterColumn({required this.title, required this.links});

  FooterColumn copyWith({String? title, List<FooterLink>? links}) =>
      FooterColumn(title: title ?? this.title, links: links ?? this.links);

  Map<String, dynamic> toJson() =>
      {'title': title, 'links': links.map((l) => l.toJson()).toList()};

  factory FooterColumn.fromJson(Map<String, dynamic> j) => FooterColumn(
        title: j['title'] as String? ?? '',
        links: (j['links'] as List?)
                ?.map((e) => e is Map
                    ? FooterLink.fromJson(e.cast<String, dynamic>())
                    // Migrate old string-only links.
                    : FooterLink(label: e.toString()))
                .toList() ??
            const [],
      );
}

/// A footer social icon: an [icon] key, a destination [url] (internal route or
/// external link), and whether it's shown. Each is individually toggleable.
class SocialLink {
  final String icon; // key: instagram | email | heart | mail | phone | facebook | link | shop
  final String url;
  final bool enabled;
  const SocialLink({required this.icon, this.url = '', this.enabled = true});

  /// Icon keys the manager can choose from.
  static const iconKeys = [
    'instagram',
    'email',
    'mail',
    'heart',
    'phone',
    'facebook',
    'shop',
    'link',
  ];

  SocialLink copyWith({String? icon, String? url, bool? enabled}) => SocialLink(
        icon: icon ?? this.icon,
        url: url ?? this.url,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() =>
      {'icon': icon, 'url': url, 'enabled': enabled};

  factory SocialLink.fromJson(Map<String, dynamic> j) => SocialLink(
        icon: j['icon'] as String? ?? 'link',
        url: j['url'] as String? ?? '',
        enabled: j['enabled'] as bool? ?? true,
      );
}
