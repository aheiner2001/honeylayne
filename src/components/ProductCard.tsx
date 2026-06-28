import { Heart } from 'lucide-react';

import type { Product } from '../types';
import { openExternal } from '../lib/util';
import { ProductImage } from './ProductImage';

export function ProductCard({ product }: { product: Product }) {
  const open = () => {
    if (product.instagramUrl) openExternal(product.instagramUrl);
  };

  return (
    <button
      type="button"
      onClick={open}
      className="group block w-full overflow-hidden rounded-2xl bg-white/55 text-left shadow-[0_8px_14px_rgba(239,160,176,0.14)] transition-all duration-200 hover:-translate-y-1 hover:shadow-[0_8px_22px_rgba(239,160,176,0.28)]"
    >
      <div className="aspect-[0.82/1] w-full overflow-hidden">
        <ProductImage imageUrl={product.imageUrl} className="h-full w-full" />
      </div>
      <div className="flex items-center gap-2 px-3.5 pb-3.5 pt-3">
        <div className="min-w-0 flex-1">
          <p className="truncate font-cormorant text-[17px] font-semibold text-pinkDeep">
            {product.name}
          </p>
          <p className="font-quicksand text-[13px] text-inkSoft">
            ${product.price.toFixed(2)}
          </p>
        </div>
        <Heart className="shrink-0 text-pink" size={18} />
      </div>
    </button>
  );
}
