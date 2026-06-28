import { useState } from 'react';
import { X, Trash2, ShoppingBag } from 'lucide-react';

import { useCart } from '../store/CartStore';
import { startCheckout } from '../data/checkout';
import { ProductImage } from './ProductImage';

export function CartDrawer() {
  const cart = useCart();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const checkout = async () => {
    setError(null);
    setBusy(true);
    try {
      await startCheckout(cart.items);
    } catch (e: any) {
      setError(e?.message ?? 'Checkout failed. Please try again.');
      setBusy(false);
    }
  };

  return (
    <>
      {/* Scrim */}
      <div
        onClick={cart.close}
        className={`fixed inset-0 z-40 bg-pinkDeep/20 transition-opacity ${
          cart.isOpen ? 'opacity-100' : 'pointer-events-none opacity-0'
        }`}
      />

      {/* Panel */}
      <aside
        className={`fixed right-0 top-0 z-50 flex h-full w-full max-w-[380px] flex-col bg-blush shadow-[-12px_0_30px_rgba(239,160,176,0.25)] transition-transform duration-300 ${
          cart.isOpen ? 'translate-x-0' : 'translate-x-full'
        }`}
        aria-hidden={!cart.isOpen}
      >
        <div className="flex items-center gap-2 border-b border-blushDeep px-5 py-4">
          <ShoppingBag className="text-pink" size={20} />
          <h2 className="font-cormorant text-xl font-semibold text-pinkDeep">
            Your Cart
          </h2>
          <span className="font-quicksand text-[13px] text-inkSoft">
            ({cart.count})
          </span>
          <button
            type="button"
            onClick={cart.close}
            className="ml-auto text-inkSoft hover:text-pinkDeep"
            aria-label="Close cart"
          >
            <X size={22} />
          </button>
        </div>

        {cart.items.length === 0 ? (
          <div className="flex flex-1 flex-col items-center justify-center px-6 text-center">
            <ShoppingBag className="text-pinkSoft" size={44} />
            <p className="mt-3 font-cormorant text-lg text-pinkDeep">
              Your cart is empty
            </p>
            <p className="mt-1 font-quicksand text-[13px] text-inkSoft">
              Add a piece you love to get started.
            </p>
            <button
              type="button"
              onClick={cart.close}
              className="mt-5 rounded-full bg-pink px-6 py-3 font-quicksand text-[13px] font-semibold tracking-wide text-white transition-colors hover:bg-pinkDeep"
            >
              KEEP SHOPPING
            </button>
          </div>
        ) : (
          <>
            <div className="flex-1 overflow-y-auto px-5 py-4">
              <div className="flex flex-col gap-3">
                {cart.items.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center gap-3 rounded-xl bg-white/55 p-2.5"
                  >
                    <div className="h-16 w-[54px] shrink-0 overflow-hidden rounded-lg">
                      <ProductImage imageUrl={item.imageUrl} className="h-full w-full" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-cormorant text-base text-pinkDeep">
                        {item.name}
                      </p>
                      <p className="font-quicksand text-[13px] text-inkSoft">
                        ${item.price.toFixed(2)}
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => cart.remove(item.id)}
                      className="text-inkSoft hover:text-pinkDeep"
                      aria-label={`Remove ${item.name}`}
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>
                ))}
              </div>
            </div>

            <div className="border-t border-blushDeep px-5 py-4">
              <div className="flex items-center justify-between">
                <span className="font-quicksand text-[13px] text-inkSoft">Subtotal</span>
                <span className="font-cormorant text-lg font-semibold text-pinkDeep">
                  ${cart.subtotal.toFixed(2)}
                </span>
              </div>
              <p className="mt-1 font-quicksand text-xs text-inkSoft">
                Pickup, local delivery, or shipping is chosen at checkout.
              </p>
              {error && (
                <p className="mt-2 font-quicksand text-[13px] text-pinkDeep">{error}</p>
              )}
              <button
                type="button"
                onClick={checkout}
                disabled={busy}
                className="mt-3 w-full rounded-full bg-pink py-3.5 font-quicksand text-[13px] font-semibold tracking-[1.5px] text-white transition-colors hover:bg-pinkDeep disabled:opacity-60"
              >
                {busy ? 'STARTING CHECKOUT…' : 'CHECKOUT'}
              </button>
            </div>
          </>
        )}
      </aside>
    </>
  );
}
