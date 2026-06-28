import { initializeApp, type FirebaseApp } from 'firebase/app';
import { getFirestore, type Firestore } from 'firebase/firestore';
import { getStorage, type FirebaseStorage } from 'firebase/storage';
import { getAuth, type Auth } from 'firebase/auth';

const env = import.meta.env;

const firebaseConfig = {
  apiKey: env.VITE_FIREBASE_API_KEY as string,
  appId: env.VITE_FIREBASE_APP_ID as string,
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID as string,
  projectId: env.VITE_FIREBASE_PROJECT_ID as string,
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN as string,
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET as string,
};

/** True when real Firebase web config was supplied at build time. */
export const firebaseConfigured = Boolean(firebaseConfig.apiKey);

let app: FirebaseApp | null = null;
let _db: Firestore | null = null;
let _storage: FirebaseStorage | null = null;
let _auth: Auth | null = null;

export function initFirebase(): boolean {
  if (!firebaseConfigured) return false;
  try {
    app = initializeApp(firebaseConfig);
    _db = getFirestore(app);
    _storage = getStorage(app);
    _auth = getAuth(app);
    return true;
  } catch (e) {
    // Never blank the site if Firebase has a hiccup — fall back to local.
    console.error('FIREBASE_INIT_FAILED', e);
    return false;
  }
}

export function db(): Firestore {
  if (!_db) throw new Error('Firestore not initialized');
  return _db;
}

export function storage(): FirebaseStorage {
  if (!_storage) throw new Error('Storage not initialized');
  return _storage;
}

export function auth(): Auth {
  if (!_auth) throw new Error('Auth not initialized');
  return _auth;
}
