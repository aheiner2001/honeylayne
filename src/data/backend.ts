import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  writeBatch,
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';

import {
  productFromJson,
  productToJson,
  settingsFromJson,
  settingsToJson,
  type Product,
  type SiteSettings,
} from '../types';
import { db, storage } from './firebase';

/** Storage abstraction: localStorage today, Firebase when configured. */
export interface HoneyBackend {
  loadProducts(): Promise<Product[] | null>;
  loadSettings(): Promise<SiteSettings | null>;
  saveProducts(products: Product[]): Promise<void>;
  saveSettings(settings: SiteSettings): Promise<void>;
  /** Persists an uploaded image; returns a data URI (local) or https URL. */
  uploadImage(file: File, key: string): Promise<string>;
  /** Like uploadImage but keeps PNG (transparency) for header art/icons. */
  uploadImagePng(file: File, key: string): Promise<string>;
}

function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

/** Browser localStorage backend. Images are kept inline as data URIs. */
export class LocalBackend implements HoneyBackend {
  async loadProducts(): Promise<Product[] | null> {
    const raw = localStorage.getItem('hl_products');
    if (!raw) return null;
    try {
      return (JSON.parse(raw) as any[]).map(productFromJson);
    } catch {
      return null;
    }
  }

  async loadSettings(): Promise<SiteSettings | null> {
    const raw = localStorage.getItem('hl_settings');
    if (!raw) return null;
    try {
      return settingsFromJson(JSON.parse(raw));
    } catch {
      return null;
    }
  }

  async saveProducts(products: Product[]): Promise<void> {
    localStorage.setItem('hl_products', JSON.stringify(products.map(productToJson)));
  }

  async saveSettings(settings: SiteSettings): Promise<void> {
    localStorage.setItem('hl_settings', JSON.stringify(settingsToJson(settings)));
  }

  async uploadImage(file: File): Promise<string> {
    return fileToDataUrl(file);
  }

  async uploadImagePng(file: File): Promise<string> {
    return fileToDataUrl(file);
  }
}

/** Firestore + Storage backend. */
export class FirebaseBackend implements HoneyBackend {
  async loadProducts(): Promise<Product[] | null> {
    const snap = await getDocs(collection(db(), 'products'));
    if (snap.empty) return null;
    return snap.docs.map((d) => productFromJson({ ...d.data(), id: d.id }));
  }

  async loadSettings(): Promise<SiteSettings | null> {
    const d = await getDoc(doc(db(), 'site', 'settings'));
    if (!d.exists()) return null;
    return settingsFromJson(d.data());
  }

  async saveProducts(products: Product[]): Promise<void> {
    const col = collection(db(), 'products');
    const existing = await getDocs(col);
    const keep = new Set(products.map((p) => p.id));
    const batch = writeBatch(db());
    existing.docs.forEach((d) => {
      if (!keep.has(d.id)) batch.delete(d.ref);
    });
    products.forEach((p) => {
      batch.set(doc(col, p.id), productToJson(p));
    });
    await batch.commit();
  }

  async saveSettings(settings: SiteSettings): Promise<void> {
    await setDoc(doc(db(), 'site', 'settings'), settingsToJson(settings));
  }

  async uploadImage(file: File, key: string): Promise<string> {
    const r = ref(storage(), `products/${key}.jpg`);
    await uploadBytes(r, file, { contentType: file.type || 'image/jpeg' });
    return getDownloadURL(r);
  }

  async uploadImagePng(file: File, key: string): Promise<string> {
    const r = ref(storage(), `header/${key}.png`);
    await uploadBytes(r, file, { contentType: 'image/png' });
    return getDownloadURL(r);
  }
}
