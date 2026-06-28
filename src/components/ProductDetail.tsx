import { useEffect } from 'react';
import { X, Check, Plus, Instagram } from 'lucide-react';

import type { Product } from '../types';
import { useCart } from '../store/CartStore';
import { openExternal } from '../lib/util';
import { ImageCarousel } from './ImageCarousel';

export function ProductDetail({
  product,
  onClose,
}: {
  product: Product;
  onClose: () => void;
}) {
  const cart = useCart();
  const inCart = cart.has(product.id);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-[55] flex items-center justify-center bg-pinkDeep/25 p-4"
      onClick={onClose}
    >
      <div
        className="relative max-h-[92vh] w-full max-w-[860px] overflow-y-auto rounded-[22px] bg-blush shadow-xl md:overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          type="button"
          onClick={onClose}
          aria-label="Close"
          className="absolute right-3 top-3 z-10 flex h-9 w-9 items-center justify-center rounded-full bg-white/80 text-pinkDeep shadow-sm hover:bg-white"
        >
          <X size={20} />
        </button>

        <div className="grid md:grid-cols-2">
          <div className="relative aspect-[0.82/1] w-full bg-cream">
            <ImageCarousel
              images={product.images}
              showArrows
              objectFit="contain"
              className="h-full w-full"
            />
            {product.sold && (
              <div className="pointer-events-none absolute left-3 top-3 rounded-full bg-pinkDeep px-3 py-1 font-quicksand text-[11px] font-semibold tracking-wide text-white">
                SOLD
              </div>
            )}
          </div>

          <div className="flex flex-col p-6 md:p-7">
            <p className="font-quicksand text-[12px] uppercase tracking-[1.5px] text-inkSoft">
              {product.category}
            </p>
            <h2 className="mt-1 font-cormorant text-3xl font-semibold text-pinkDeep">
              {product.name}
            </h2>
            <p className="mt-1.5 font-cormorant text-2xl text-ink">
              ${product.price.toFixed(2)}
            </p>

            {product.size && (
              <p className="mt-3 font-quicksand text-[13px] text-ink">
                <span className="font-semibold text-pinkDeep">Size:</span> {product.size}
              </p>
            )}

            {product.description ? (
              <p className="mt-3 whitespace-pre-line font-quicksand text-[13px] leading-relaxed text-inkSoft">
                {product.description}
              </p>
            ) : (
              <p className="mt-3 font-quicksand text-[13px] leading-relaxed text-inkSoft">
                One-of-a-kind, handmade piece. Once it’s gone, it’s gone.
              </p>
            )}

            <p className="mt-3 font-quicksand text-[12px] leading-relaxed text-inkSoft">
              Choose free pickup in Nampa, local delivery, or shipping at checkout.
            </p>

            <div className="mt-auto pt-6">
              {product.sold ? (
                <button
                  type="button"
                  disabled
                  className="w-full cursor-not-allowed rounded-full bg-blushDeep py-3.5 font-quicksand text-[13px] font-semibold tracking-wide text-inkSoft"
                >
                  SOLD OUT
                </button>
              ) : inCart ? (
                <button
                  type="button"
                  onClick={() => {
                    onClose();
                    cart.open();
                  }}
                  className="flex w-full items-center justify-center gap-1.5 rounded-full bg-pinkDeep/10 py-3.5 font-quicksand text-[13px] font-semibold tracking-wide text-pinkDeep"
                >
                  <Check size={16} /> IN CART — VIEW
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => cart.add(product)}
                  className="flex w-full items-center justify-center gap-1.5 rounded-full bg-pink py-3.5 font-quicksand text-[13px] font-semibold tracking-wide text-white transition-colors hover:bg-pinkDeep"
                >
                  <Plus size={16} /> ADD TO CART
                </button>
              )}

              {product.instagramUrl && (
                <button
                  type="button"
                  onClick={() => openExternal(product.instagramUrl)}
                  className="mt-2.5 flex w-full items-center justify-center gap-1.5 rounded-full border border-pinkSoft py-3 font-quicksand text-[12px] font-semibold tracking-wide text-pinkDeep transition-colors hover:bg-white/50"
                >
                  <Instagram size={15} /> VIEW ON INSTAGRAM
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
