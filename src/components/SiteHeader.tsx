import { Link, useNavigate } from 'react-router-dom';
import { Heart } from 'lucide-react';

import { useStore } from '../store/HoneyStore';
import { routeForNav } from '../types';
import { resolveSrc, openExternal } from '../lib/util';

function DecoImage({ url, className }: { url: string; className?: string }) {
  const src = resolveSrc(url);
  if (!src) return null;
  return <img src={src} alt="" aria-hidden className={`object-contain ${className ?? ''}`} />;
}

export function SiteHeader({ active = 'Home' }: { active?: string }) {
  const { settings, visibleNav } = useStore();
  const navigate = useNavigate();

  const shopLink = settings.contactInstagram || 'https://www.instagram.com/_honeylayne/';

  return (
    <header className="relative overflow-hidden bg-gradient-to-b from-headerTop to-headerBottom">
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
