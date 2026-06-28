import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Eye,
  EyeOff,
  ExternalLink,
  LogOut,
  Plus,
  Pencil,
  Trash2,
  Camera,
  ChevronDown,
} from 'lucide-react';

import { useStore } from '../store/HoneyStore';
import {
  CATEGORIES,
  FEATURE_ICON_KEYS,
  LOCKED_NAV,
  ORDERED_NAV,
  SECTIONS,
  SOCIAL_ICON_KEYS,
  defaultSettings,
  type FeatureItem,
  type FooterColumn,
  type FooterLink,
  type Product,
  type SiteSettings,
  type SocialLink,
} from '../types';
import {
  Field,
  ImagePickField,
  PinkButton,
  SectionCard,
  Switch,
  ToastHost,
  ToggleChip,
  useToast,
} from '../components/manager/ui';
import { ProductImage } from '../components/ProductImage';
import { FeatureIcon, SocialIcon } from '../components/icons';

export function ManagerPage() {
  const store = useStore();
  return (
    <ToastHost>
      {store.managerUnlocked ? <Dashboard /> : <PasswordGate />}
    </ToastHost>
  );
}

// ---------------------------------------------------------------------------
function PasswordGate() {
  const store = useStore();
  const [code, setCode] = useState('');
  const [error, setError] = useState(false);
  const [obscure, setObscure] = useState(true);
  const [busy, setBusy] = useState(false);

  const submit = async () => {
    setBusy(true);
    const ok = await store.unlock(code);
    setBusy(false);
    if (!ok) setError(true);
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-headerTop to-blush px-6">
      <div className="w-full max-w-[380px] rounded-[22px] bg-white/70 p-8 shadow-[0_18px_40px_rgba(239,160,176,0.2)]">
        <h1 className="text-center font-logo text-[44px]">Honey Layne</h1>
        <p className="mt-1 text-center font-cormorant text-lg font-semibold text-pinkDeep">
          Manager Studio
        </p>
        <p className="mt-4 text-center font-quicksand text-[13px] text-inkSoft">
          Enter the access code to continue.
        </p>
        <div className="mt-5 flex items-center rounded-xl bg-cream">
          <input
            type={obscure ? 'password' : 'text'}
            value={code}
            autoFocus
            placeholder="Access code"
            onChange={(e) => {
              setCode(e.target.value);
              setError(false);
            }}
            onKeyDown={(e) => e.key === 'Enter' && submit()}
            className="w-full bg-transparent px-3.5 py-3.5 font-cormorant text-base text-ink outline-none"
          />
          <button
            type="button"
            onClick={() => setObscure((v) => !v)}
            className="px-3 text-pink"
          >
            {obscure ? <EyeOff size={20} /> : <Eye size={20} />}
          </button>
        </div>
        {error && (
          <p className="mt-2 font-quicksand text-[13px] text-pinkDeep">
            That code didn't match. Please try again.
          </p>
        )}
        <div className="mt-5 flex justify-center">
          <PinkButton label={busy ? 'CHECKING…' : 'ENTER STUDIO'} onClick={submit} />
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function ManagerHeader() {
  const navigate = useNavigate();
  const store = useStore();
  return (
    <div className="flex items-center bg-gradient-to-b from-headerTop to-headerBottom px-7 py-[18px]">
      <span className="font-logo text-[38px]">Honey Layne</span>
      <span className="ml-2.5 mt-1.5 font-cormorant text-base font-semibold text-pinkDeep">
        Manager Studio
      </span>
      <div className="ml-auto flex items-center gap-2">
        <button
          type="button"
          onClick={() => navigate('/')}
          className="flex items-center gap-1.5 font-quicksand text-[13px] text-pinkDeep"
        >
          <ExternalLink size={16} /> View store
        </button>
        <button
          type="button"
          onClick={() => store.lock()}
          className="flex items-center gap-1.5 font-quicksand text-[13px] text-pinkDeep"
        >
          <LogOut size={16} /> Log out
        </button>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function Dashboard() {
  const store = useStore();
  const s = store.settings;

  // Bump a key whenever settings identity changes so editors reset to saved
  // values after a save (mirrors the Flutter ValueKey(hashCode) behavior).
  const revRef = useRef(0);
  const prevRef = useRef<SiteSettings>(s);
  if (prevRef.current !== s) {
    prevRef.current = s;
    revRef.current += 1;
  }
  const rev = revRef.current;

  const [editing, setEditing] = useState<Product | null | undefined>(undefined);
  // undefined = closed; null = adding new; Product = editing.

  return (
    <div className="min-h-screen bg-blush">
      <ManagerHeader />
      <div className="px-4 py-7 md:px-12">
        <div className="mx-auto flex max-w-[1100px] flex-col gap-[22px]">
          <SectionCard
            title="Access code"
            subtitle="The code required to open this studio. Change it anytime."
          >
            <PasswordChanger key={`pw-${s.managerPassword}`} current={s.managerPassword} />
          </SectionCard>

          <SectionCard
            title="Menu visibility"
            subtitle="Turn the top-bar links on or off. Home and Shop All always stay on."
          >
            <NavToggles />
          </SectionCard>

          <SectionCard
            title="Page sections"
            subtitle="Show or hide whole sections on each page."
          >
            <SectionToggles />
          </SectionCard>

          <SectionCard
            title="Header decorations"
            subtitle="Upload your own PNGs for the top-left art, top-right art, and shop icon. Transparent PNGs look best."
          >
            <HeaderEditor key={`header-${rev}`} settings={s} />
          </SectionCard>

          <SectionCard
            title="Home page"
            subtitle="Hero headline, welcome text, button, photo, and the favorites title."
          >
            <HomeEditor key={`home-${rev}`} settings={s} />
          </SectionCard>

          <SectionCard
            title="About page · Our Story"
            subtitle="Heading, story paragraphs, photo, and the four highlights."
          >
            <AboutEditor key={`about-${rev}`} settings={s} />
          </SectionCard>

          <SectionCard
            title="Contact page"
            subtitle="The greeting and how customers can reach you."
          >
            <ContactEditor key={`contact-${rev}`} settings={s} />
          </SectionCard>

          <SectionCard
            title="Footer"
            subtitle="The tagline, link columns, and social icons at the bottom of every page."
          >
            <FooterEditor key={`footer-${rev}`} settings={s} />
          </SectionCard>

          <SectionCard
            title="Products"
            subtitle="Add a photo from your phone, set a price, and paste the Instagram link."
            trailing={
              <PinkButton
                label="ADD PRODUCT"
                icon={<Plus size={16} />}
                onClick={() => setEditing(null)}
              />
            }
          >
            <ProductList products={store.products} onEdit={(p) => setEditing(p)} />
          </SectionCard>
        </div>
      </div>

      {editing !== undefined && (
        <ProductEditor existing={editing} onClose={() => setEditing(undefined)} />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
function PasswordChanger({ current }: { current: string }) {
  const store = useStore();
  const toast = useToast();
  const [value, setValue] = useState(current);
  const [obscure, setObscure] = useState(true);

  const save = () => {
    if (!value.trim()) return;
    store.updateManagerPassword(value);
    toast('Access code updated.');
  };

  return (
    <div className="flex items-start gap-3">
      <div className="flex flex-1 items-center rounded-xl bg-cream">
        <input
          type={obscure ? 'password' : 'text'}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && save()}
          placeholder="Access code"
          className="w-full bg-transparent px-3.5 py-3.5 font-cormorant text-base text-ink outline-none"
        />
        <button type="button" onClick={() => setObscure((v) => !v)} className="px-3 text-pink">
          {obscure ? <EyeOff size={20} /> : <Eye size={20} />}
        </button>
      </div>
      <PinkButton label="SAVE" onClick={save} />
    </div>
  );
}

// ---------------------------------------------------------------------------
function NavToggles() {
  const store = useStore();
  const s = store.settings;
  return (
    <div className="flex flex-wrap gap-3">
      {ORDERED_NAV.map((label) => (
        <ToggleChip
          key={label}
          label={label}
          value={s.navEnabled[label] ?? true}
          locked={LOCKED_NAV.has(label)}
          onChange={(v) => store.toggleNav(label, v)}
        />
      ))}
    </div>
  );
}

function SectionToggles() {
  const store = useStore();
  const s = store.settings;
  return (
    <div className="flex flex-wrap gap-3">
      {Object.entries(SECTIONS).map(([id, label]) => (
        <ToggleChip
          key={id}
          label={label}
          value={s.sectionVisible[id] ?? true}
          onChange={(v) => store.toggleSection(id, v)}
        />
      ))}
    </div>
  );
}

// ---------------------------------------------------------------------------
function HeaderEditor({ settings }: { settings: SiteSettings }) {
  const store = useStore();
  const toast = useToast();
  const [left, setLeft] = useState(settings.headerLeftImageUrl);
  const [right, setRight] = useState(settings.headerRightImageUrl);
  const [icon, setIcon] = useState(settings.headerShopIconUrl);
  const [shopLink, setShopLink] = useState(settings.contactInstagram);

  const save = () => {
    store.updateSettings({
      ...store.settings,
      headerLeftImageUrl: left,
      headerRightImageUrl: right,
      headerShopIconUrl: icon,
      contactInstagram: shopLink.trim(),
    });
    toast('Saved');
  };

  const reset = () => {
    const d = defaultSettings();
    store.updateSettings({
      ...store.settings,
      headerLeftImageUrl: d.headerLeftImageUrl,
      headerRightImageUrl: d.headerRightImageUrl,
      headerShopIconUrl: d.headerShopIconUrl,
    });
    toast('Saved');
  };

  return (
    <div>
      <div className="flex flex-wrap gap-[18px]">
        <ImagePickField label="Top-left art" imageUrl={left} storageKey="header_left" png onChange={setLeft} />
        <ImagePickField label="Top-right art" imageUrl={right} storageKey="header_right" png onChange={setRight} />
        <ImagePickField label="Shop icon" imageUrl={icon} storageKey="header_shop_icon" png onChange={setIcon} />
      </div>
      <div className="mt-4">
        <Field
          label="Instagram shop link (opens when the shop icon is tapped)"
          value={shopLink}
          onChange={setShopLink}
        />
      </div>
      <div className="mt-3.5 flex items-center justify-end gap-3">
        <button type="button" onClick={reset} className="font-quicksand text-[13px] text-pink">
          Reset to defaults
        </button>
        <PinkButton label="SAVE HEADER" onClick={save} />
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function HomeEditor({ settings }: { settings: SiteSettings }) {
  const store = useStore();
  const toast = useToast();
  const [line1, setLine1] = useState(settings.heroTitleLine1);
  const [line2, setLine2] = useState(settings.heroTitleLine2);
  const [subtitle, setSubtitle] = useState(settings.heroSubtitle);
  const [button, setButton] = useState(settings.heroButtonLabel);
  const [favTitle, setFavTitle] = useState(settings.favoritesTitle);
  const [heroImage, setHeroImage] = useState(settings.heroImageUrl);

  const save = () => {
    store.updateSettings({
      ...store.settings,
      heroTitleLine1: line1,
      heroTitleLine2: line2,
      heroSubtitle: subtitle,
      heroButtonLabel: button,
      favoritesTitle: favTitle,
      heroImageUrl: heroImage,
    });
    toast('Saved');
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-col gap-[18px] md:flex-row">
        <ImagePickField label="Hero photo" imageUrl={heroImage} storageKey="hero" onChange={setHeroImage} />
        <div className="flex flex-1 flex-col gap-3">
          <div className="flex flex-col gap-3 md:flex-row">
            <div className="flex-1">
              <Field label="Headline line 1" value={line1} onChange={setLine1} />
            </div>
            <div className="flex-1">
              <Field label="Headline line 2" value={line2} onChange={setLine2} />
            </div>
          </div>
          <Field label="Welcome text" value={subtitle} onChange={setSubtitle} />
        </div>
      </div>
      <div className="flex flex-col gap-3 md:flex-row">
        <div className="flex-1">
          <Field label="Button label" value={button} onChange={setButton} />
        </div>
        <div className="flex-1">
          <Field label="Favorites section title" value={favTitle} onChange={setFavTitle} />
        </div>
      </div>
      <div className="flex justify-end">
        <PinkButton label="SAVE HOME" onClick={save} />
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function IconSelect({
  value,
  options,
  kind,
  onChange,
}: {
  value: string;
  options: string[];
  kind: 'feature' | 'social';
  onChange: (v: string) => void;
}) {
  return (
    <div className="flex h-[50px] items-center gap-2 rounded-xl bg-cream px-2.5">
      {kind === 'feature' ? (
        <FeatureIcon name={value} className="text-pinkDeep" size={22} />
      ) : (
        <SocialIcon name={value} className="text-pink" size={20} />
      )}
      <div className="relative flex items-center">
        <select
          value={options.includes(value) ? value : options[0]}
          onChange={(e) => onChange(e.target.value)}
          className="appearance-none bg-transparent pr-5 font-quicksand text-[13px] text-ink outline-none"
        >
          {options.map((k) => (
            <option key={k} value={k}>
              {k}
            </option>
          ))}
        </select>
        <ChevronDown className="pointer-events-none -ml-4 text-pink" size={16} />
      </div>
    </div>
  );
}

function AboutEditor({ settings }: { settings: SiteSettings }) {
  const store = useStore();
  const toast = useToast();
  const [title, setTitle] = useState(settings.aboutTitle);
  const [body1, setBody1] = useState(settings.aboutBody1);
  const [body2, setBody2] = useState(settings.aboutBody2);
  const [thanks, setThanks] = useState(settings.aboutThankYou);
  const [image, setImage] = useState(settings.aboutImageUrl);
  const [features, setFeatures] = useState<FeatureItem[]>([...settings.aboutFeatures]);

  const setFeature = (i: number, patch: Partial<FeatureItem>) =>
    setFeatures((arr) => arr.map((f, idx) => (idx === i ? { ...f, ...patch } : f)));

  const save = () => {
    store.updateSettings({
      ...store.settings,
      aboutTitle: title,
      aboutBody1: body1,
      aboutBody2: body2,
      aboutThankYou: thanks,
      aboutImageUrl: image,
      aboutFeatures: features,
    });
    toast('Saved');
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-col gap-[18px] md:flex-row">
        <ImagePickField label="Story photo" imageUrl={image} storageKey="about" onChange={setImage} />
        <div className="flex flex-1 flex-col gap-3">
          <Field label="Heading" value={title} onChange={setTitle} />
          <Field label="Closing line" value={thanks} onChange={setThanks} />
        </div>
      </div>
      <Field label="Story paragraph 1" value={body1} onChange={setBody1} multiline rows={3} />
      <Field label="Story paragraph 2" value={body2} onChange={setBody2} multiline rows={3} />
      <p className="font-cormorant text-base font-semibold text-pinkDeep">Highlights</p>
      {features.map((f, i) => (
        <div key={i} className="flex items-end gap-3">
          <IconSelect
            value={f.icon}
            options={FEATURE_ICON_KEYS}
            kind="feature"
            onChange={(v) => setFeature(i, { icon: v })}
          />
          <div className="flex-1">
            <Field
              label={`Highlight ${i + 1}`}
              value={f.text}
              onChange={(v) => setFeature(i, { text: v })}
            />
          </div>
        </div>
      ))}
      <div className="flex justify-end">
        <PinkButton label="SAVE ABOUT" onClick={save} />
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function ContactEditor({ settings }: { settings: SiteSettings }) {
  const store = useStore();
  const toast = useToast();
  const [title, setTitle] = useState(settings.contactTitle);
  const [blurb, setBlurb] = useState(settings.contactBlurb);
  const [email, setEmail] = useState(settings.contactEmail);
  const [instagram, setInstagram] = useState(settings.contactInstagram);
  const [phone, setPhone] = useState(settings.contactPhone);

  const save = () => {
    store.updateSettings({
      ...store.settings,
      contactTitle: title,
      contactBlurb: blurb,
      contactEmail: email,
      contactInstagram: instagram,
      contactPhone: phone,
    });
    toast('Saved');
  };

  return (
    <div className="flex flex-col gap-3">
      <Field label="Heading" value={title} onChange={setTitle} />
      <Field label="Greeting text" value={blurb} onChange={setBlurb} multiline rows={3} />
      <div className="flex flex-col gap-3 md:flex-row">
        <div className="flex-1">
          <Field label="Email" value={email} onChange={setEmail} />
        </div>
        <div className="flex-1">
          <Field label="Phone (optional)" value={phone} onChange={setPhone} />
        </div>
      </div>
      <Field label="Instagram link" value={instagram} onChange={setInstagram} />
      <div className="flex justify-end">
        <PinkButton label="SAVE CONTACT" onClick={save} />
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function linkToLine(l: FooterLink): string {
  return l.url ? `${l.label} | ${l.url}` : l.label;
}
function lineToLink(line: string): FooterLink {
  const i = line.indexOf('|');
  if (i < 0) return { label: line.trim(), url: '' };
  return { label: line.slice(0, i).trim(), url: line.slice(i + 1).trim() };
}

function FooterEditor({ settings }: { settings: SiteSettings }) {
  const store = useStore();
  const toast = useToast();
  const [tagline, setTagline] = useState(settings.footerTagline);
  const [titles, setTitles] = useState<string[]>(settings.footerColumns.map((c) => c.title));
  const [links, setLinks] = useState<string[]>(
    settings.footerColumns.map((c) => c.links.map(linkToLine).join('\n')),
  );
  const [socials, setSocials] = useState<SocialLink[]>([...settings.footerSocials]);

  const setSocial = (i: number, patch: Partial<SocialLink>) =>
    setSocials((arr) => arr.map((s, idx) => (idx === i ? { ...s, ...patch } : s)));

  const save = () => {
    const cols: FooterColumn[] = titles.map((title, i) => ({
      title,
      links: links[i]
        .split('\n')
        .filter((e) => e.trim().length > 0)
        .map(lineToLink),
    }));
    store.updateSettings({
      ...store.settings,
      footerTagline: tagline,
      footerColumns: cols,
      footerSocials: socials,
    });
    toast('Saved');
  };

  return (
    <div className="flex flex-col gap-3">
      <Field label="Tagline (under the logo)" value={tagline} onChange={setTagline} />
      <p className="font-quicksand text-xs text-inkSoft">
        Links: one per line. To make a link clickable add " | link" after the name — e.g.
        "Dresses | /shop/Dresses" for a page on this site, or "Instagram |
        https://instagram.com/_honeylayne/" for an outside link. No "|" = plain text.
      </p>
      <div className="flex flex-wrap gap-4">
        {titles.map((t, i) => (
          <div key={i} className="w-[260px]">
            <Field
              label={`Column ${i + 1} title`}
              value={t}
              onChange={(v) => setTitles((arr) => arr.map((x, idx) => (idx === i ? v : x)))}
            />
            <div className="mt-2">
              <Field
                label="Links (Name | link)"
                value={links[i]}
                multiline
                rows={6}
                onChange={(v) => setLinks((arr) => arr.map((x, idx) => (idx === i ? v : x)))}
              />
            </div>
          </div>
        ))}
      </div>

      <hr className="my-2 border-blushDeep" />
      <p className="font-cormorant text-lg font-semibold text-pinkDeep">Social icons</p>
      <p className="font-quicksand text-xs text-inkSoft">
        The little icons under the logo. Toggle each on/off, pick an icon, and set where it goes —
        an outside link (https://…, mailto:you@…) or a page on this site (/shop, /contact).
      </p>
      {socials.map((s, i) => (
        <div key={i} className="flex items-center gap-3">
          <Switch checked={s.enabled} onChange={(v) => setSocial(i, { enabled: v })} />
          <div className="flex items-center gap-2 rounded-xl bg-cream px-2 py-1.5">
            <SocialIcon name={s.icon} className="text-pink" size={18} />
            <select
              value={SOCIAL_ICON_KEYS.includes(s.icon) ? s.icon : 'link'}
              onChange={(e) => setSocial(i, { icon: e.target.value })}
              className="bg-transparent font-quicksand text-[13px] text-ink outline-none"
            >
              {SOCIAL_ICON_KEYS.map((k) => (
                <option key={k} value={k}>
                  {k}
                </option>
              ))}
            </select>
          </div>
          <div className="flex-1">
            <Field
              label="Link (https://… , mailto:… , or /shop)"
              value={s.url}
              onChange={(v) => setSocial(i, { url: v })}
            />
          </div>
          <button
            type="button"
            title="Remove"
            onClick={() => setSocials((arr) => arr.filter((_, idx) => idx !== i))}
            className="text-inkSoft hover:text-pinkDeep"
          >
            <Trash2 size={20} />
          </button>
        </div>
      ))}
      <button
        type="button"
        onClick={() => setSocials((arr) => [...arr, { icon: 'link', url: '', enabled: true }])}
        className="flex items-center gap-1.5 self-start font-quicksand text-[13px] font-semibold text-pinkDeep"
      >
        <Plus size={18} /> Add icon
      </button>

      <div className="flex justify-end">
        <PinkButton label="SAVE FOOTER" onClick={save} />
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
function ProductList({
  products,
  onEdit,
}: {
  products: Product[];
  onEdit: (p: Product) => void;
}) {
  const store = useStore();
  if (products.length === 0) {
    return (
      <p className="py-6 font-quicksand text-inkSoft">
        No products yet. Tap “Add product” to begin.
      </p>
    );
  }
  return (
    <div className="flex flex-col gap-3">
      {products.map((p) => (
        <div key={p.id} className="flex items-center gap-3.5 rounded-xl bg-blush/60 p-2.5">
          <div className="h-16 w-[54px] overflow-hidden rounded-lg">
            <ProductImage imageUrl={p.imageUrl} className="h-full w-full" />
          </div>
          <div className="flex-1">
            <p className="font-cormorant text-lg text-pinkDeep">{p.name}</p>
            <p className="font-quicksand text-xs text-inkSoft">
              {p.category}  •  ${p.price.toFixed(2)}
            </p>
          </div>
          <button type="button" onClick={() => onEdit(p)} className="text-pink">
            <Pencil size={20} />
          </button>
          <button type="button" onClick={() => store.removeProduct(p.id)} className="text-pinkDeep">
            <Trash2 size={20} />
          </button>
        </div>
      ))}
    </div>
  );
}

// ---------------------------------------------------------------------------
function ProductEditor({
  existing,
  onClose,
}: {
  existing: Product | null;
  onClose: () => void;
}) {
  const store = useStore();
  const toast = useToast();
  const fileRef = useRef<HTMLInputElement>(null);
  const pendingId = useRef(existing?.id ?? `p_${Date.now()}`);

  const [name, setName] = useState(existing?.name ?? '');
  const [price, setPrice] = useState(existing ? existing.price.toFixed(2) : '');
  const [instagram, setInstagram] = useState(existing?.instagramUrl ?? '');
  const [category, setCategory] = useState(existing?.category ?? 'Dresses');
  const [imageUrl, setImageUrl] = useState(existing?.imageUrl ?? '');
  const [favorite, setFavorite] = useState(existing?.favorite ?? true);
  const [uploading, setUploading] = useState(false);

  const pick = async (file: File | undefined) => {
    if (!file) return;
    setUploading(true);
    try {
      const url = await store.uploadProductImage(file, pendingId.current);
      setImageUrl(url);
    } catch (e) {
      toast(`Image upload failed: ${e}`);
    } finally {
      setUploading(false);
    }
  };

  const save = () => {
    const product: Product = {
      id: pendingId.current,
      name: name.trim() || 'New Piece',
      price: parseFloat(price.trim()) || 0,
      category,
      imageUrl,
      instagramUrl: instagram.trim(),
      favorite,
    };
    if (existing) store.updateProduct(product);
    else store.addProduct(product);
    onClose();
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-pinkDeep/20 p-4"
      onClick={onClose}
    >
      <div
        className="max-h-[90vh] w-full max-w-[460px] overflow-y-auto rounded-[20px] bg-blush p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="font-cormorant text-2xl font-semibold text-pinkDeep">
          {existing ? 'Edit product' : 'Add product'}
        </h2>
        <div className="mt-[18px] flex justify-center">
          <button
            type="button"
            onClick={() => fileRef.current?.click()}
            className="flex h-[180px] w-[150px] items-center justify-center overflow-hidden rounded-xl border-[1.4px] border-pinkSoft bg-cream"
          >
            {uploading ? (
              <span className="h-6 w-6 animate-spin rounded-full border-2 border-pink border-t-transparent" />
            ) : imageUrl ? (
              <ProductImage imageUrl={imageUrl} className="h-full w-full" />
            ) : (
              <span className="flex flex-col items-center text-pink">
                <Camera size={30} />
                <span className="mt-2 font-quicksand text-[13px]">Add photo</span>
              </span>
            )}
          </button>
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => pick(e.target.files?.[0] ?? undefined)}
          />
        </div>
        <div className="mt-[18px] flex flex-col gap-3">
          <Field label="Name" value={name} onChange={setName} />
          <div className="flex gap-3">
            <div className="flex-1">
              <Field label="Price" value={price} onChange={setPrice} prefix="$" type="number" />
            </div>
            <div className="flex-1">
              <span className="mb-1.5 block font-quicksand text-xs font-semibold text-inkSoft">
                Category
              </span>
              <div className="flex items-center rounded-xl bg-cream px-3">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full bg-transparent py-3.5 font-cormorant text-base text-ink outline-none"
                >
                  {CATEGORIES.map((c) => (
                    <option key={c} value={c}>
                      {c}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
          <Field
            label="Instagram link"
            value={instagram}
            onChange={setInstagram}
            hint="https://instagram.com/p/..."
          />
          <div className="flex items-center gap-2">
            <Switch checked={favorite} onChange={setFavorite} />
            <span className="font-quicksand text-[13px] text-ink">
              Show in “Shop Our Favorites”
            </span>
          </div>
        </div>
        <div className="mt-[18px] flex items-center justify-end gap-2.5">
          <button type="button" onClick={onClose} className="font-quicksand text-sm text-inkSoft">
            Cancel
          </button>
          <PinkButton label="SAVE" onClick={save} />
        </div>
      </div>
    </div>
  );
}
