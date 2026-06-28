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
    this.contactInstagram = 'https://instagram.com/honeylayne',
    this.contactPhone = '',
    this.footerTagline = 'Romantic pieces made\nto make you feel beautiful.',
    this.footerColumns = defaultFooterColumns,
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

  static const defaultFooterColumns = [
    FooterColumn(title: 'Shop', links: ['Dresses', 'Tops', 'Bottoms', 'Accessories', 'Shop All']),
    FooterColumn(title: 'Help', links: ['Shipping & Returns', 'FAQs', 'Size Guide', 'Contact Us']),
    FooterColumn(title: 'About', links: ['Our Story', 'Sustainability', 'Lookbook', 'Careers']),
    FooterColumn(title: 'Legal', links: ['Terms of Service', 'Privacy Policy', 'Accessibility']),
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

class FooterColumn {
  final String title;
  final List<String> links;
  const FooterColumn({required this.title, required this.links});

  FooterColumn copyWith({String? title, List<String>? links}) =>
      FooterColumn(title: title ?? this.title, links: links ?? this.links);

  Map<String, dynamic> toJson() => {'title': title, 'links': links};
  factory FooterColumn.fromJson(Map<String, dynamic> j) => FooterColumn(
        title: j['title'] as String? ?? '',
        links: (j['links'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}
