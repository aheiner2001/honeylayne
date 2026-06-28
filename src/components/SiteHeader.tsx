import { Link, useNavigate } from 'react-router-dom';
import { Heart, ShoppingBag } from 'lucide-react';

import { useStore } from '../store/HoneyStore';
import { useCart } from '../store/CartStore';
import { routeForNav } from '../types';
import { resolveSrc, openExternal } from '../lib/util';

function DecoImage({ url, className }: { url: string; className?: string }) {
  const src = resolveSrc(url);
  if (!src) return null;
  return <img src={src} alt="" aria-hidden className={`object-contain ${className ?? ''}`} />;
}

export function SiteHeader({
  active = 'Home',
  flat = false,
}: {
  active?: string;
  /** When true the header is transparent, so a parent gradient can flow
   * through it (used on the home page to fade into the hero). */
  flat?: boolean;
}) {
  const { settings, visibleNav } = useStore();
  const cart = useCart();
  const navigate = useNavigate();

  const shopLink = settings.contactInstagram || 'https://www.instagram.com/_honeylayne/';

  return (
    <header
      className={`relative overflow-hidden ${
        flat ? '' : 'bg-gradient-to-b from-[#FCEFB0] to-blush'
      }`}
    >
      {/* Top-left art (bees by default). */}
      <DecoImage
        url={settings.headerLeftImageUrl}
        className="pointer-events-none absolute -left-2 top-1 w-[110px] md:top-1.5 md:w-[190px]"
      />
      {/* Top-right art (florals by default). */}
      <DecoImage
        url={settings.headerRightImageUrl}
        className="pointer-events-none absolute right-0 top-0 w-[140px] md:w-[250px]"
      />

      {/* Cart */}
      <button
        type="button"
        onClick={cart.open}
        aria-label={`Open cart (${cart.count} item${cart.count === 1 ? '' : 's'})`}
        className="absolute right-3 top-3 z-30 flex h-10 w-10 items-center justify-center rounded-full bg-white/70 text-pinkDeep shadow-sm transition-colors hover:bg-white md:right-5 md:top-5"
      >
        <ShoppingBag size={20} />
        {cart.count > 0 && (
          <span className="absolute -right-1 -top-1 flex h-5 min-w-[20px] items-center justify-center rounded-full bg-pinkDeep px-1 font-quicksand text-[11px] font-semibold text-white">
            {cart.count}
          </span>
        )}
      </button>

      <div className="relative px-6 py-6 md:py-9">
        <div className="flex flex-col items-center">
          {/* Wordmark */}
          <Link to="/" className="flex items-center gap-1.5 md:gap-2.5">
            <span className="font-logo text-[40px] leading-none md:text-[56px]">
              Honey Layne
            </span>
            <Heart className="mt-1.5 text-pink md:mt-2.5" size={16} />
          </Link>

          <div className="relative mt-2 flex w-full items-center justify-center md:mt-2.5">
            <nav className="flex flex-wrap items-center justify-center gap-x-5 gap-y-1.5">
              {visibleNav.map((item) => {
                const isActive = item === active;
                return (
                  <button
                    key={item}
                    type="button"
                    onClick={() => navigate(routeForNav(item))}
                    className="group flex flex-col items-center"
                  >
                    <span
                      className={`font-cormorant text-base transition-colors ${
                        isActive
                          ? 'font-semibold text-pinkDeep'
                          : 'font-medium text-pink group-hover:text-pinkDeep'
                      }`}
                    >
                      {item}
                    </span>
                    <span
                      className={`mt-0.5 h-[1.5px] rounded bg-pinkDeep transition-all ${
                        isActive ? 'w-5' : 'w-0'
                      }`}
                    />
                  </button>
                );
              })}
            </nav>

            {/* Shop icon -> Instagram (desktop, inset from the corner florals). */}
            <button
              type="button"
              title="Shop on Instagram"
              onClick={() => openExternal(shopLink)}
              className="absolute right-[140px] hidden md:block"
            >
              <DecoImage url={settings.headerShopIconUrl} className="h-[30px] w-[30px]" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
