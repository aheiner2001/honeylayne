import { useParams } from 'react-router-dom';
import { Flower2 } from 'lucide-react';

import { useStore } from '../store/HoneyStore';
import { SiteHeader } from '../components/SiteHeader';
import { SiteFooter } from '../components/SiteFooter';
import { ProductCard } from '../components/ProductCard';
import { PageDecor } from '../components/PageDecor';

export function ShopPage() {
  const { category } = useParams<{ category?: string }>();
  const { products, byCategory } = useStore();

  const items = category ? byCategory(category) : products;
  const title = category ?? 'Shop All';
  const active = category ?? 'Shop All';

  return (
    <div className="relative isolate min-h-screen overflow-hidden bg-blush">
      <PageDecor sprigs={false} />
      <SiteHeader active={active} />

      <div className="px-4 pb-2 pt-7 text-center md:px-10 md:pt-11">
        <h1 className="font-script text-[44px] md:text-[56px]">{title}</h1>
        <p className="mt-1.5 font-quicksand text-[13px] text-inkSoft">
          {items.length} piece{items.length === 1 ? '' : 's'}
        </p>
      </div>

      <div className="px-3.5 py-4 md:px-10">
        {items.length === 0 ? (
          <div className="flex flex-col items-center py-16">
            <Flower2 className="text-pinkSoft" size={48} />
            <p className="mt-3.5 font-cormorant text-xl text-pinkDeep">
              New pieces coming soon
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-[18px] min-[760px]:grid-cols-3 min-[980px]:grid-cols-4">
            {items.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        )}
      </div>

      <div className="h-9" />
      <SiteFooter />
    </div>
  );
}
