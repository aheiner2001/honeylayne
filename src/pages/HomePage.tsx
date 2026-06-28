import { useNavigate } from 'react-router-dom';
import { Heart, ArrowRight } from 'lucide-react';

import { useStore } from '../store/HoneyStore';
import { sectionOn } from '../types';
import { SiteHeader } from '../components/SiteHeader';
import { SiteFooter } from '../components/SiteFooter';
import { ProductCard } from '../components/ProductCard';
import { ProductImage } from '../components/ProductImage';
import { resolveSrc } from '../lib/util';

function ShopNowButton({ label }: { label: string }) {
  const navigate = useNavigate();
  return (
    <button
      type="button"
      onClick={() => navigate('/shop')}
      className="rounded-full bg-pink px-[34px] py-[15px] font-quicksand text-[13px] font-semibold tracking-[1.5px] text-white shadow-[0_8px_16px_rgba(239,160,176,0.45)] transition-colors hover:bg-pinkDeep"
    >
      {label}
    </button>
  );
}

function Polaroid({ imageUrl }: { imageUrl: string }) {
  return (
    <div className="relative">
      <div className="rotate-[2deg] rounded bg-white p-3 pb-3.5 shadow-[0_12px_22px_rgba(0,0,0,0.18)]">
        <div className="h-[200px] w-[220px] overflow-hidden rounded-sm md:h-[230px] md:w-[250px]">
          <ProductImage imageUrl={imageUrl} className="h-full w-full" />
        </div>
      </div>
      <div className="absolute -top-2.5 left-1/2 h-6 w-[86px] -translate-x-1/2 -rotate-2 bg-pinkSoft/80" />
      <Heart className="absolute -bottom-1.5 right-1.5 text-pinkDeep" size={22} />
    </div>
  );
}

export function HomePage() {
  const { settings, favorites } = useStore();
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-blush">
      <SiteHeader active="Home" />

      {sectionOn(settings, 'home.hero') && (
        <div className="px-3.5 py-4 md:px-7 md:py-5">
          <div className="relative overflow-hidden rounded-[18px] bg-heroPanel">
            {/* Floral accent, bottom-left, mirrored. */}
            <img
              src={resolveSrc('assets/images/floral_topright.png')}
              alt=""
              aria-hidden
              className="pointer-events-none absolute -bottom-10 -left-8 w-[150px] -rotate-[8deg] -scale-x-100 object-contain md:w-[210px]"
            />
            <div className="relative flex flex-col items-center gap-7 px-6 py-7 md:flex-row md:px-14 md:py-10">
              <div className="flex flex-1 flex-col items-center text-center md:items-start md:text-left">
                <h1 className="font-script text-[44px] md:text-[64px]">
                  {settings.heroTitleLine1}
                </h1>
                <h1 className="font-script text-[44px] md:text-[64px]">
                  {settings.heroTitleLine2}
                </h1>
                <p className="mt-3.5 max-w-[360px] font-cormorant text-[17px] font-medium text-ink">
                  {settings.heroSubtitle}
                </p>
                <div className="mt-6">
                  <ShopNowButton label={settings.heroButtonLabel} />
                </div>
              </div>
              <Polaroid imageUrl={settings.heroImageUrl} />
            </div>
          </div>
        </div>
      )}

      {sectionOn(settings, 'home.favorites') && (
        <section className="px-3.5 md:px-7">
          <div className="flex items-center">
            <Heart className="text-pink" size={18} />
            <h2 className="ml-2 font-cormorant text-2xl font-semibold text-pinkDeep">
              {settings.favoritesTitle}
            </h2>
            <button
              type="button"
              onClick={() => navigate('/shop')}
              className="ml-auto flex items-center gap-1 font-quicksand text-[13px] text-pink"
            >
              View all <ArrowRight size={14} />
            </button>
          </div>
          <div className="mt-4 grid grid-cols-2 gap-[18px] min-[520px]:grid-cols-3 min-[760px]:grid-cols-4 min-[980px]:grid-cols-5">
            {favorites.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </section>
      )}

      <div className="h-9" />
      <SiteFooter />
    </div>
  );
}
