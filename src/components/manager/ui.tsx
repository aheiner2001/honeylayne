import {
  createContext,
  useContext,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import { Plus, Camera } from 'lucide-react';

import { useStore } from '../../store/HoneyStore';
import { ProductImage } from '../ProductImage';

// ---- Toast ----
const ToastContext = createContext<(msg: string) => void>(() => {});
export const useToast = () => useContext(ToastContext);

export function ToastHost({ children }: { children: ReactNode }) {
  const [msg, setMsg] = useState<string | null>(null);
  const timer = useRef<number | undefined>(undefined);
  const show = (m: string) => {
    setMsg(m);
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => setMsg(null), 1600);
  };
  return (
    <ToastContext.Provider value={show}>
      {children}
      {msg && (
        <div className="fixed bottom-6 left-1/2 z-50 -translate-x-1/2 rounded-lg bg-ink/90 px-5 py-3 font-quicksand text-sm text-white shadow-lg">
          {msg}
        </div>
      )}
    </ToastContext.Provider>
  );
}

// ---- Buttons ----
export function PinkButton({
  label,
  onClick,
  icon,
}: {
  label: string;
  onClick: () => void;
  icon?: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="inline-flex items-center gap-1.5 rounded-full bg-pink px-[22px] py-3.5 font-quicksand text-[13px] font-semibold tracking-wide text-white transition-colors hover:bg-pinkDeep"
    >
      {icon}
      {label}
    </button>
  );
}

// ---- Field (label + input/textarea) ----
export function Field({
  label,
  value,
  onChange,
  hint,
  prefix,
  type = 'text',
  multiline,
  rows = 6,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  hint?: string;
  prefix?: string;
  type?: string;
  multiline?: boolean;
  rows?: number;
}) {
  const base =
    'w-full rounded-xl bg-cream px-3.5 py-3.5 font-cormorant text-base text-ink outline-none placeholder:text-inkSoft/70';
  return (
    <label className="block">
      <span className="mb-1.5 block font-quicksand text-xs font-semibold text-inkSoft">
        {label}
      </span>
      {multiline ? (
        <textarea
          value={value}
          rows={rows}
          placeholder={hint}
          onChange={(e) => onChange(e.target.value)}
          className={`${base} resize-y`}
        />
      ) : (
        <div className="flex items-center rounded-xl bg-cream">
          {prefix && <span className="pl-3.5 font-cormorant text-base text-ink">{prefix}</span>}
          <input
            type={type}
            value={value}
            placeholder={hint}
            onChange={(e) => onChange(e.target.value)}
            className={`${base} ${prefix ? 'pl-1' : ''}`}
          />
        </div>
      )}
    </label>
  );
}

// ---- Section card ----
export function SectionCard({
  title,
  subtitle,
  trailing,
  children,
}: {
  title: string;
  subtitle: string;
  trailing?: ReactNode;
  children: ReactNode;
}) {
  return (
    <div className="w-full rounded-[18px] bg-white/60 p-6 shadow-[0_8px_18px_rgba(239,160,176,0.1)]">
      <div className="flex items-start">
        <div className="flex-1">
          <h3 className="font-cormorant text-[22px] font-semibold text-pinkDeep">{title}</h3>
          <p className="mt-1 font-quicksand text-[13px] text-inkSoft">{subtitle}</p>
        </div>
        {trailing}
      </div>
      <div className="mt-[18px]">{children}</div>
    </div>
  );
}

// ---- Toggle chip ----
export function ToggleChip({
  label,
  value,
  locked,
  onChange,
}: {
  label: string;
  value: boolean;
  locked?: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <div
      className={`flex items-center gap-2 rounded-full border px-4 py-2 ${
        value ? 'border-pink bg-pink/15' : 'border-blushDeep bg-cream'
      }`}
    >
      <span
        className={`font-cormorant text-base font-semibold ${
          locked ? 'text-inkSoft' : 'text-pinkDeep'
        }`}
      >
        {label}
      </span>
      <Switch checked={value} disabled={locked} onChange={onChange} />
    </div>
  );
}

// ---- Switch ----
export function Switch({
  checked,
  disabled,
  onChange,
}: {
  checked: boolean;
  disabled?: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={() => !disabled && onChange(!checked)}
      className={`relative h-6 w-11 shrink-0 rounded-full transition-colors ${
        checked ? 'bg-pink' : 'bg-inkSoft/40'
      } ${disabled ? 'opacity-50' : ''}`}
      aria-pressed={checked}
    >
      <span
        className={`absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all ${
          checked ? 'left-[22px]' : 'left-0.5'
        }`}
      />
    </button>
  );
}

// ---- Image pick field ----
export function ImagePickField({
  label,
  imageUrl,
  storageKey,
  png = false,
  onChange,
}: {
  label: string;
  imageUrl: string;
  storageKey: string;
  png?: boolean;
  onChange: (url: string) => void;
}) {
  const store = useStore();
  const toast = useToast();
  const [url, setUrl] = useState(imageUrl);
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const pick = async (file: File | undefined) => {
    if (!file) return;
    setUploading(true);
    try {
      const next = png
        ? await store.uploadImagePng(file, storageKey)
        : await store.uploadImage(file, storageKey);
      setUrl(next);
      onChange(next);
    } catch (e) {
      toast(`Image upload failed: ${e}`);
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <span className="mb-1.5 block font-quicksand text-xs font-semibold text-inkSoft">
        {label}
      </span>
      <button
        type="button"
        onClick={() => inputRef.current?.click()}
        className="flex h-[150px] w-[140px] items-center justify-center overflow-hidden rounded-xl border-[1.4px] border-pinkSoft bg-cream"
      >
        {uploading ? (
          <span className="h-6 w-6 animate-spin rounded-full border-2 border-pink border-t-transparent" />
        ) : url ? (
          <ProductImage imageUrl={url} className="h-full w-full" objectFit={png ? 'contain' : 'cover'} />
        ) : (
          <span className="flex flex-col items-center text-pink">
            <Camera size={28} />
            <span className="mt-2 font-quicksand text-xs">Add photo</span>
          </span>
        )}
      </button>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={(e) => pick(e.target.files?.[0] ?? undefined)}
      />
    </div>
  );
}

export { Plus };
