import {
  Heart,
  Camera,
  AtSign,
  Mail,
  Phone,
  Facebook,
  ShoppingBag,
  Link2,
  Leaf,
  Flower2,
  Star,
  Sparkles,
  type LucideProps,
} from 'lucide-react';

// Footer / header social icon by key (mirrors the Flutter mapping).
export function SocialIcon({ name, ...props }: { name: string } & LucideProps) {
  switch (name) {
    case 'instagram':
      return <Camera {...props} />;
    case 'email':
      return <AtSign {...props} />;
    case 'mail':
      return <Mail {...props} />;
    case 'heart':
      return <Heart {...props} />;
    case 'phone':
      return <Phone {...props} />;
    case 'facebook':
      return <Facebook {...props} />;
    case 'shop':
      return <ShoppingBag {...props} />;
    case 'link':
    default:
      return <Link2 {...props} />;
  }
}

// About-page feature highlight icon by key.
export function FeatureIcon({ name, ...props }: { name: string } & LucideProps) {
  switch (name) {
    case 'leaf':
      return <Leaf {...props} />;
    case 'flower':
      return <Flower2 {...props} />;
    case 'bag':
      return <ShoppingBag {...props} />;
    case 'star':
      return <Star {...props} />;
    case 'sparkle':
      return <Sparkles {...props} />;
    case 'heart':
    default:
      return <Heart {...props} />;
  }
}
