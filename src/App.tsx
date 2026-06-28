import { useEffect, useState } from 'react';
import { Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom';

import { useStore } from './store/HoneyStore';
import { useCart } from './store/CartStore';
import { HomePage } from './pages/HomePage';
import { ShopPage } from './pages/ShopPage';
import { AboutPage } from './pages/AboutPage';
import { ContactPage } from './pages/ContactPage';
import { ManagerPage } from './pages/ManagerPage';
import { CartDrawer } from './components/CartDrawer';
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

/** Banner shown briefly after returning from Stripe Checkout. */
function CheckoutBanner({ message, onClose }: { message: string; onClose: () => void }) {
  useEffect(() => {
    const t = window.setTimeout(onClose, 6000);
    return () => window.clearTimeout(t);
  }, [onClose]);
  return (
    <div className="fixed bottom-6 left-1/2 z-[60] -translate-x-1/2 rounded-full bg-pinkDeep px-6 py-3 font-quicksand text-sm text-white shadow-lg">
      {message}
    </div>
  );
}

/** Reads ?checkout=success|cancel on return from Stripe: clears the cart on
 * success and shows a friendly banner, then strips the query param. */
function useCheckoutReturn(): { banner: string | null; dismiss: () => void } {
  const cart = useCart();
  const location = useLocation();
  const navigate = useNavigate();
  const [banner, setBanner] = useState<string | null>(null);

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const status = params.get('checkout');
    if (!status) return;
    if (status === 'success') {
      cart.clear();
      setBanner('Thank you! Your order is confirmed. 🐝');
    } else if (status === 'cancel') {
      setBanner('Checkout canceled — your cart is saved.');
    }
    params.delete('checkout');
    navigate({ pathname: location.pathname, search: params.toString() }, { replace: true });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { banner, dismiss: () => setBanner(null) };
}

export default function App() {
  const { loaded } = useStore();
  const [fontsReady, setFontsReady] = useState(false);
  const { banner, dismiss } = useCheckoutReturn();

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
    <>
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
      <CartDrawer />
      {banner && <CheckoutBanner message={banner} onClose={dismiss} />}
    </>
  );
}
