// All app data models + (de)serialization, ported from the Flutter app.

export interface Product {
  id: string;
  name: string;
  price: number;
  category: string; // Dresses, Tops, Bottoms, Accessories
  size: string; // e.g. "Small", "M", "One size", "Fits 4-6"
  description: string; // details about the piece
  imageUrl: string; // primary image (kept in sync with images[0] for back-compat)
  images: string[]; // gallery: network urls, asset paths, or data uris
  instagramUrl: string; // hyperlink to buy / IG post
  favorite: boolean; // featured in "Shop Our Favorites"
  sold: boolean; // one-of-a-kind: hidden from buying once sold
}

export function productFromJson(j: any): Product {
  const rawImages: string[] = Array.isArray(j.images)
    ? j.images.map((x: any) => String(x)).filter(Boolean)
    : [];
  const primary = (j.imageUrl as string) || rawImages[0] || '';
  const images = rawImages.length > 0 ? rawImages : primary ? [primary] : [];
  return {
    id: String(j.id),
    name: String(j.name ?? ''),
    price: Number(j.price ?? 0),
    category: (j.category as string) || 'Dresses',
    size: (j.size as string) || '',
    description: (j.description as string) || '',
    imageUrl: images[0] ?? '',
    images,
    instagramUrl: (j.instagramUrl as string) || '',
    favorite: j.favorite ?? true,
    sold: j.sold ?? false,
  };
}

export function productToJson(p: Product): Record<string, unknown> {
  const images = p.images && p.images.length > 0 ? p.images : p.imageUrl ? [p.imageUrl] : [];
  return {
    id: p.id,
    name: p.name,
    price: p.price,
    category: p.category,
    size: p.size,
    description: p.description,
    imageUrl: images[0] ?? '',
    images,
    instagramUrl: p.instagramUrl,
    favorite: p.favorite,
    sold: p.sold,
  };
}

export interface FeatureItem {
  icon: string; // leaf | heart | flower | bag | star | sparkle
  text: string;
}

export interface FooterLink {
  label: string;
  url: string; // internal route ("/shop") or external link; "" = plain text
}

export interface FooterColumn {
  title: string;
  links: FooterLink[];
}

export interface SocialLink {
  icon: string; // instagram | email | mail | heart | phone | facebook | shop | link
  url: string;
  enabled: boolean;
}

export const SOCIAL_ICON_KEYS = [
  'instagram',
  'email',
  'mail',
  'heart',
  'phone',
  'facebook',
  'shop',
  'link',
];

export const FEATURE_ICON_KEYS = ['leaf', 'heart', 'flower', 'bag', 'star', 'sparkle'];

export const CATEGORIES = ['Dresses', 'Tops', 'Bottoms', 'Accessories'];

export interface SiteSettings {
  navEnabled: Record<string, boolean>;
  sectionVisible: Record<string, boolean>;

  heroTitleLine1: string;
  heroTitleLine2: string;
  heroSubtitle: string;
  heroButtonLabel: string;
  heroImageUrl: string;
  favoritesTitle: string;

  aboutTitle: string;
  aboutBody1: string;
  aboutBody2: string;
  aboutThankYou: string;
  aboutImageUrl: string;
  aboutFeatures: FeatureItem[];

  contactTitle: string;
  contactBlurb: string;
  contactEmail: string;
  contactInstagram: string;
  contactPhone: string;

  footerTagline: string;
  footerColumns: FooterColumn[];
  footerSocials: SocialLink[];

  headerLeftImageUrl: string;
  headerRightImageUrl: string;
  headerShopIconUrl: string;

  managerPassword: string;
}

export const ORDERED_NAV = [
  'Home',
  'Shop All',
  'Dresses',
  'Tops',
  'Bottoms',
  'Accessories',
  'About',
  'Contact',
];

export const LOCKED_NAV = new Set(['Home', 'Shop All']);

// Toggleable page sections: id -> human label (shown in the studio).
export const SECTIONS: Record<string, string> = {
  'home.hero': 'Home · Hero banner',
  'home.favorites': 'Home · Shop Our Favorites',
  'about.story': 'About · Our Story',
  'about.features': 'About · Feature highlights',
  'contact.details': 'Contact · Details',
  footer: 'Footer',
};

const DEFAULT_FEATURES: FeatureItem[] = [
  { icon: 'leaf', text: 'Feminine and timeless designs' },
  { icon: 'heart', text: 'Made to make you feel beautiful inside and out' },
  { icon: 'flower', text: 'Inspired by nature, flowers, and sunny days' },
  { icon: 'bag', text: 'Thoughtful details in every piece' },
];

const DEFAULT_SOCIALS: SocialLink[] = [
  { icon: 'instagram', url: 'https://www.instagram.com/_honeylayne/', enabled: true },
  { icon: 'email', url: 'mailto:hello@honeylayne.shop', enabled: true },
  { icon: 'heart', url: '/shop', enabled: true },
  { icon: 'mail', url: '/contact', enabled: true },
];

const DEFAULT_FOOTER_COLUMNS: FooterColumn[] = [
  {
    title: 'Shop',
    links: [
      { label: 'Dresses', url: '/shop/Dresses' },
      { label: 'Tops', url: '/shop/Tops' },
      { label: 'Bottoms', url: '/shop/Bottoms' },
      { label: 'Accessories', url: '/shop/Accessories' },
      { label: 'Shop All', url: '/shop' },
    ],
  },
  {
    title: 'Help',
    links: [
      { label: 'Contact Us', url: '/contact' },
      { label: 'Shipping & Returns', url: '' },
      { label: 'FAQs', url: '' },
      { label: 'Size Guide', url: '' },
    ],
  },
  {
    title: 'About',
    links: [
      { label: 'Our Story', url: '/about' },
      { label: 'Sustainability', url: '' },
      { label: 'Lookbook', url: '' },
      { label: 'Careers', url: '' },
    ],
  },
  {
    title: 'Legal',
    links: [
      { label: 'Terms of Service', url: '' },
      { label: 'Privacy Policy', url: '' },
      { label: 'Accessibility', url: '' },
    ],
  },
];

export function defaultSettings(): SiteSettings {
  return {
    navEnabled: Object.fromEntries(ORDERED_NAV.map((n) => [n, true])),
    sectionVisible: Object.fromEntries(Object.keys(SECTIONS).map((s) => [s, true])),
    heroTitleLine1: 'Sweet style',
    heroTitleLine2: 'for sunny days',
    heroSubtitle: 'Romantic pieces made to make you feel beautiful.',
    heroButtonLabel: 'SHOP NOW',
    heroImageUrl: 'assets/images/hero_model.png',
    favoritesTitle: 'Shop Our Favorites',
    aboutTitle: 'Our Story',
    aboutBody1:
      'Honey Layne was created with a love for romantic style, soft details, and the beauty of everyday moments.',
    aboutBody2:
      'We believe that what you wear should make you feel confident, feminine, and like the best version of yourself.',
    aboutThankYou: 'Thank you for being here',
    aboutImageUrl: 'assets/images/hero_model.png',
    aboutFeatures: DEFAULT_FEATURES,
    contactTitle: 'Say Hello',
    contactBlurb:
      "We'd love to hear from you — questions, custom requests, or just to say hi.",
    contactEmail: 'hello@honeylayne.shop',
    contactInstagram: 'https://www.instagram.com/_honeylayne/',
    contactPhone: '',
    footerTagline: 'Romantic pieces made\nto make you feel beautiful.',
    footerColumns: DEFAULT_FOOTER_COLUMNS,
    footerSocials: DEFAULT_SOCIALS,
    headerLeftImageUrl: 'assets/images/bees_trail.png',
    headerRightImageUrl: 'assets/images/floral_topright.png',
    headerShopIconUrl: 'assets/images/shop_icon.png',
    managerPassword: 'honeybee',
  };
}

export function settingsToJson(s: SiteSettings): Record<string, unknown> {
  return {
    navEnabled: s.navEnabled,
    sectionVisible: s.sectionVisible,
    heroTitleLine1: s.heroTitleLine1,
    heroTitleLine2: s.heroTitleLine2,
    heroSubtitle: s.heroSubtitle,
    heroButtonLabel: s.heroButtonLabel,
    heroImageUrl: s.heroImageUrl,
    favoritesTitle: s.favoritesTitle,
    aboutTitle: s.aboutTitle,
    aboutBody1: s.aboutBody1,
    aboutBody2: s.aboutBody2,
    aboutThankYou: s.aboutThankYou,
    aboutImageUrl: s.aboutImageUrl,
    aboutFeatures: s.aboutFeatures,
    contactTitle: s.contactTitle,
    contactBlurb: s.contactBlurb,
    contactEmail: s.contactEmail,
    contactInstagram: s.contactInstagram,
    contactPhone: s.contactPhone,
    footerTagline: s.footerTagline,
    footerColumns: s.footerColumns,
    footerSocials: s.footerSocials,
    headerLeftImageUrl: s.headerLeftImageUrl,
    headerRightImageUrl: s.headerRightImageUrl,
    headerShopIconUrl: s.headerShopIconUrl,
    managerPassword: s.managerPassword,
  };
}

function nonEmpty(v: any, fallback: string): string {
  return typeof v === 'string' && v.length > 0 ? v : fallback;
}

export function settingsFromJson(j: any): SiteSettings {
  const d = defaultSettings();
  const nav = (j.navEnabled ?? {}) as Record<string, any>;
  const sec = (j.sectionVisible ?? {}) as Record<string, any>;

  const features: FeatureItem[] | undefined = Array.isArray(j.aboutFeatures)
    ? j.aboutFeatures.map((e: any) => ({
        icon: (e?.icon as string) || 'heart',
        text: (e?.text as string) || '',
      }))
    : undefined;

  const cols: FooterColumn[] | undefined = Array.isArray(j.footerColumns)
    ? j.footerColumns.map((c: any) => ({
        title: (c?.title as string) || '',
        links: Array.isArray(c?.links)
          ? c.links.map((e: any) =>
              typeof e === 'object' && e !== null
                ? { label: (e.label as string) || '', url: (e.url as string) || '' }
                : { label: String(e), url: '' },
            )
          : [],
      }))
    : undefined;

  const socials: SocialLink[] | undefined = Array.isArray(j.footerSocials)
    ? j.footerSocials.map((e: any) => ({
        icon: (e?.icon as string) || 'link',
        url: (e?.url as string) || '',
        enabled: e?.enabled ?? true,
      }))
    : undefined;

  return {
    navEnabled: Object.fromEntries(ORDERED_NAV.map((n) => [n, nav[n] ?? true])),
    sectionVisible: Object.fromEntries(
      Object.keys(SECTIONS).map((s) => [s, sec[s] ?? true]),
    ),
    heroTitleLine1: j.heroTitleLine1 ?? d.heroTitleLine1,
    heroTitleLine2: j.heroTitleLine2 ?? d.heroTitleLine2,
    heroSubtitle: j.heroSubtitle ?? d.heroSubtitle,
    heroButtonLabel: j.heroButtonLabel ?? d.heroButtonLabel,
    heroImageUrl: j.heroImageUrl ?? d.heroImageUrl,
    favoritesTitle: j.favoritesTitle ?? d.favoritesTitle,
    aboutTitle: j.aboutTitle ?? d.aboutTitle,
    aboutBody1: j.aboutBody1 ?? j.storyText ?? d.aboutBody1,
    aboutBody2: j.aboutBody2 ?? d.aboutBody2,
    aboutThankYou: j.aboutThankYou ?? d.aboutThankYou,
    aboutImageUrl: j.aboutImageUrl ?? d.aboutImageUrl,
    aboutFeatures: features && features.length > 0 ? features : DEFAULT_FEATURES,
    contactTitle: j.contactTitle ?? d.contactTitle,
    contactBlurb: j.contactBlurb ?? d.contactBlurb,
    contactEmail: j.contactEmail ?? d.contactEmail,
    contactInstagram: j.contactInstagram ?? d.contactInstagram,
    contactPhone: j.contactPhone ?? d.contactPhone,
    footerTagline: j.footerTagline ?? d.footerTagline,
    footerColumns: cols && cols.length > 0 ? cols : DEFAULT_FOOTER_COLUMNS,
    footerSocials: socials ?? DEFAULT_SOCIALS,
    headerLeftImageUrl: nonEmpty(j.headerLeftImageUrl, d.headerLeftImageUrl),
    headerRightImageUrl: nonEmpty(j.headerRightImageUrl, d.headerRightImageUrl),
    headerShopIconUrl: nonEmpty(j.headerShopIconUrl, d.headerShopIconUrl),
    managerPassword: nonEmpty(j.managerPassword, d.managerPassword),
  };
}

// ---- Derived helpers ----
export function visibleNav(s: SiteSettings): string[] {
  return ORDERED_NAV.filter((n) => s.navEnabled[n] ?? true);
}

export function sectionOn(s: SiteSettings, id: string): boolean {
  return s.sectionVisible[id] ?? true;
}

export function routeForNav(label: string): string {
  switch (label) {
    case 'Home':
      return '/';
    case 'Shop All':
      return '/shop';
    case 'About':
      return '/about';
    case 'Contact':
      return '/contact';
    default:
      return `/shop/${label}`; // Dresses, Tops, Bottoms, Accessories
  }
}
