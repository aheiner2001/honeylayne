import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import { signInAnonymously, signOut } from 'firebase/auth';

import {
  FirebaseBackend,
  LocalBackend,
  type HoneyBackend,
} from '../data/backend';
import { auth, firebaseConfigured, initFirebase } from '../data/firebase';
import { seedProducts } from '../seed';
import {
  defaultSettings,
  visibleNav as deriveVisibleNav,
  type Product,
  type SiteSettings,
  LOCKED_NAV,
} from '../types';

// Decide the backend once. Firebase when configured + initialized OK,
// otherwise the browser localStorage fallback.
const firebaseOk = firebaseConfigured && initFirebase();
export const authEnabled = firebaseOk;
const backend: HoneyBackend = firebaseOk ? new FirebaseBackend() : new LocalBackend();

interface HoneyStore {
  products: Product[];
  settings: SiteSettings;
  loaded: boolean;
  managerUnlocked: boolean;
  authEnabled: boolean;

  favorites: Product[];
  byCategory: (category: string) => Product[];
  visibleNav: string[];
  managerPassword: string;
  checkManagerPassword: (input: string) => boolean;

  // settings / nav
  toggleNav: (label: string, enabled: boolean) => void;
  toggleSection: (id: string, enabled: boolean) => void;
  updateSettings: (next: SiteSettings) => void;
  updateManagerPassword: (password: string) => void;

  // products
  addProduct: (p: Product) => void;
  updateProduct: (p: Product) => void;
  removeProduct: (id: string) => void;

  // images
  uploadProductImage: (file: File, productId: string) => Promise<string>;
  uploadImage: (file: File, key: string) => Promise<string>;
  uploadImagePng: (file: File, key: string) => Promise<string>;

  // auth
  unlock: (password: string) => Promise<boolean>;
  lock: () => void;
}

const StoreContext = createContext<HoneyStore | null>(null);

export function HoneyStoreProvider({ children }: { children: ReactNode }) {
  const [products, setProducts] = useState<Product[]>(seedProducts);
  const [settings, setSettings] = useState<SiteSettings>(defaultSettings());
  const [loaded, setLoaded] = useState(false);
  const [managerUnlocked, setManagerUnlocked] = useState(false);

  // Keep a ref to current settings so callbacks can read latest without deps.
  const settingsRef = useRef(settings);
  settingsRef.current = settings;
  const productsRef = useRef(products);
  productsRef.current = products;

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [p, s] = await Promise.all([
          backend.loadProducts(),
          backend.loadSettings(),
        ]);
        if (cancelled) return;
        if (p && p.length > 0) setProducts(p);
        if (s) setSettings(s);
      } catch {
        // Keep seed/defaults on any error.
      } finally {
        if (!cancelled) setLoaded(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const persistSettings = useCallback((next: SiteSettings) => {
    setSettings(next);
    void backend.saveSettings(next);
  }, []);

  const persistProducts = useCallback((next: Product[]) => {
    setProducts(next);
    void backend.saveProducts(next);
  }, []);

  const managerPassword = settings.managerPassword || 'honeybee';

  const checkManagerPassword = useCallback(
    (input: string) => input.trim() === (settingsRef.current.managerPassword || 'honeybee'),
    [],
  );

  const toggleNav = useCallback(
    (label: string, enabled: boolean) => {
      if (LOCKED_NAV.has(label)) return;
      const s = settingsRef.current;
      persistSettings({ ...s, navEnabled: { ...s.navEnabled, [label]: enabled } });
    },
    [persistSettings],
  );

  const toggleSection = useCallback(
    (id: string, enabled: boolean) => {
      const s = settingsRef.current;
      persistSettings({
        ...s,
        sectionVisible: { ...s.sectionVisible, [id]: enabled },
      });
    },
    [persistSettings],
  );

  const updateSettings = useCallback(
    (next: SiteSettings) => persistSettings(next),
    [persistSettings],
  );

  const updateManagerPassword = useCallback(
    (password: string) => {
      const trimmed = password.trim();
      if (!trimmed) return;
      persistSettings({ ...settingsRef.current, managerPassword: trimmed });
    },
    [persistSettings],
  );

  const addProduct = useCallback(
    (p: Product) => persistProducts([...productsRef.current, p]),
    [persistProducts],
  );

  const updateProduct = useCallback(
    (p: Product) =>
      persistProducts(productsRef.current.map((e) => (e.id === p.id ? p : e))),
    [persistProducts],
  );

  const removeProduct = useCallback(
    (id: string) => persistProducts(productsRef.current.filter((e) => e.id !== id)),
    [persistProducts],
  );

  const unlock = useCallback(async (password: string) => {
    if (password.trim() !== (settingsRef.current.managerPassword || 'honeybee')) {
      return false;
    }
    if (authEnabled) {
      try {
        if (!auth().currentUser) await signInAnonymously(auth());
      } catch {
        // Anonymous auth may not be enabled yet — studio still opens, but
        // writes will be rejected until it's turned on in the Firebase console.
      }
    }
    setManagerUnlocked(true);
    return true;
  }, []);

  const lock = useCallback(() => {
    setManagerUnlocked(false);
    if (authEnabled) {
      try {
        void signOut(auth());
      } catch {
        /* ignore */
      }
    }
  }, []);

  const value = useMemo<HoneyStore>(
    () => ({
      products,
      settings,
      loaded,
      managerUnlocked,
      authEnabled,
      favorites: products.filter((p) => p.favorite),
      byCategory: (category: string) => products.filter((p) => p.category === category),
      visibleNav: deriveVisibleNav(settings),
      managerPassword,
      checkManagerPassword,
      toggleNav,
      toggleSection,
      updateSettings,
      updateManagerPassword,
      addProduct,
      updateProduct,
      removeProduct,
      uploadProductImage: (file, productId) => backend.uploadImage(file, productId),
      uploadImage: (file, key) => backend.uploadImage(file, key),
      uploadImagePng: (file, key) => backend.uploadImagePng(file, key),
      unlock,
      lock,
    }),
    [
      products,
      settings,
      loaded,
      managerUnlocked,
      managerPassword,
      checkManagerPassword,
      toggleNav,
      toggleSection,
      updateSettings,
      updateManagerPassword,
      addProduct,
      updateProduct,
      removeProduct,
      unlock,
      lock,
    ],
  );

  return <StoreContext.Provider value={value}>{children}</StoreContext.Provider>;
}

export function useStore(): HoneyStore {
  const ctx = useContext(StoreContext);
  if (!ctx) throw new Error('useStore must be used within HoneyStoreProvider');
  return ctx;
}
