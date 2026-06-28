import { useState } from 'react';
import { Heart, Check, Plus } from 'lucide-react';

import type { Product } from '../types';
import { useCart } from '../store/CartStore';
import { ImageCarousel } from './ImageCarousel';
import { ProductDetail } from './ProductDetail';

export function ProductCard({ product }: { product: Product }) {
  const cart = useCart();
  const inCart = cart.has(product.id);
  const [detailOpen, setDetailOpen] = useState(false);

  return (
    <>
      <div className="group block w-full overflow-hidden rounded-2xl bg-white/55 text-left shadow-[0_8px_14px_rgba(239,160,176,0.14)] transition-all duration-200 hover:-translate-y-1 hover:shadow-[0_8px_22px_rgba(239,160,176,0.28)]">
        <div className="relative aspect-[0.82/1] w-full overflow-hidden">
          <ImageCarousel
            images={product.images}
            showArrows
            className="h-full w-full cursor-pointer"
            onImageClick={() => setDetailOpen(true)}
          />
          {product.sold && (
            <div className="pointer-events-none absolute inset-0 flex items-center justify-center bg-white/45">
              <span className="rounded-full bg-pinkDeep px-4 py-1.5 font-quicksand text-xs font-semibold tracking-wide text-white">
                SOLD
              </span>
            </div>
          )}
        </div>

        <div className="px-3.5 pb-3.5 pt-3">
          <button
            type="button"
            onClick={() => setDetailOpen(true)}
            className="flex w-full items-center gap-2 text-left"
          >
            <div className="min-w-0 flex-1">
              <p className="truncate font-cormorant text-[17px] font-semibold text-pinkDeep">
                {product.name}
              </p>
              <p className="font-quicksand text-[13px] text-inkSoft">
                ${product.price.toFixed(2)}
              </p>
            </div>
            <Heart className="shrink-0 text-pink" size={18} />
          </button>

          {product.sold ? (
            <button
              type="button"
              disabled
              className="mt-2.5 w-full cursor-not-allowed rounded-full bg-blushDeep py-2.5 font-quicksand text-[12px] font-semibold tracking-wide text-inkSoft"
            >
              SOLD OUT
            </button>
          ) : inCart ? (
            <button
              type="button"
              onClick={cart.open}
              className="mt-2.5 flex w-full items-center justify-center gap-1.5 rounded-full bg-pinkDeep/10 py-2.5 font-quicksand text-[12px] font-semibold tracking-wide text-pinkDeep"
            >
              <Check size={15} /> IN CART
            </button>
          ) : (
            <button
              type="button"
              onClick={() => cart.add(product)}
              className="mt-2.5 flex w-full items-center justify-center gap-1.5 rounded-full bg-pink py-2.5 font-quicksand text-[12px] font-semibold tracking-wide text-white transition-colors hover:bg-pinkDeep"
            >
              <Plus size={15} /> ADD TO CART
            </button>
          )}
        </div>
      </div>

      {detailOpen && (
        <ProductDetail product={product} onClose={() => setDetailOpen(false)} />
      )}
    </>
  );
}
