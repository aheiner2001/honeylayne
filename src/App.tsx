import { useEffect, useState } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';

import { useStore } from './store/HoneyStore';
import { HomePage } from './pages/HomePage';
import { ShopPage } from './pages/ShopPage';
import { AboutPage } from './pages/AboutPage';
import { ContactPage } from './pages/ContactPage';
import { ManagerPage } from './pages/ManagerPage';
import { resolveSrc } from './lib/util';

/** Branded splash shown while settings + fonts load (prevents a flash of
 * unstyled content / fallback fonts). */
function Splash() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-headerTop to-blush">
      <img
        src={resolveSrc('assets/images/logo_wordmark.png')}
        alt="Honey Layne"
        className="w-60 object-contain"
      />
    </div>
  );
}

export default function App() {
  const { loaded } = useStore();
  const [fontsReady, setFontsReady] = useState(false);

  useEffect(() => {
    let mounted = true;
    const done = () => mounted && setFontsReady(true);
    const timeout = window.setTimeout(done, 5000); // never hang on slow fonts
    const ready = (document as any).fonts?.ready as Promise<unknown> | undefined;
    (ready ?? Promise.resolve()).then(() => {
      window.clearTimeout(timeout);
      done();
    });
    return () => {
      mounted = false;
      window.clearTimeout(timeout);
    };
  }, []);

  if (!loaded || !fontsReady) return <Splash />;

  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/shop" element={<ShopPage />} />
      <Route path="/shop/:category" element={<ShopPage />} />
      <Route path="/about" element={<AboutPage />} />
      <Route path="/contact" element={<ContactPage />} />
      <Route path="/manage" element={<ManagerPage />} />
      <Route path="/manager" element={<Navigate to="/manage" replace />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
