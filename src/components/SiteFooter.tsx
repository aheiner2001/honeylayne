import { useNavigate } from 'react-router-dom';

import { useStore } from '../store/HoneyStore';
import { sectionOn, type FooterColumn, type FooterLink } from '../types';
import { openExternal, resolveSrc } from '../lib/util';
import { SocialIcon } from './icons';

function FooterDecor() {
  return (
    <>
      {/* Vines — behind the footer content */}
      <div aria-hidden className="pointer-events-none absolute inset-0 -z-10 overflow-hidden">
        <img
          src={resolveSrc('assets/images/deco_vine.png')}
          alt=""
          className="absolute -left-8 -top-6 w-64 opacity-70 md:w-96"
        />
        <img
          src={resolveSrc('assets/images/deco_vine.png')}
          alt=""
          className="absolute -right-8 -top-6 hidden w-64 -scale-x-100 opacity-70 md:block md:w-96"
        />
      </div>
      {/* Bee — floating on top */}
      <img
        src={resolveSrc('assets/images/deco_bee.png')}
        alt=""
        aria-hidden
        className="pointer-events-none absolute bottom-4 right-[8%] z-20 w-16 -scale-x-100 rotate-3 md:w-20"
      />
    </>
  );
}

function useGo() {
  const navigate = useNavigate();
  return (url: string) => {
    if (!url) return;
    if (url.startsWith('/')) navigate(url);
    else openExternal(url);
  };
}

function FooterLinkText({ link, center }: { link: FooterLink; center?: boolean }) {
  const go = useGo();
  const hasLink = link.url.length > 0;
  const cls = `font-quicksand text-[13px] ${center ? 'text-center' : 'text-left'} ${
    hasLink ? 'text-ink hover:text-pinkDeep cursor-pointer' : 'text-ink'
  }`;
  if (!hasLink) return <p className={cls}>{link.label}</p>;
  return (
    <button type="button" onClick={() => go(link.url)} className={cls}>
      {link.label}
    </button>
  );
}

function FooterCol({ column, center }: { column: FooterColumn; center?: boolean }) {
  return (
    <div className={`flex flex-col ${center ? 'items-center' : 'items-start'}`}>
      <p
        className={`font-cormorant text-lg font-semibold text-pinkDeep ${
          center ? 'text-center' : 'text-left'
        }`}
      >
        {column.title}
      </p>
      <div className="mt-3 flex flex-col gap-[7px]">
        {column.links.map((l, i) => (
          <FooterLinkText key={i} link={l} center={center} />
        ))}
      </div>
    </div>
  );
}

export function SiteFooter() {
  const { settings } = useStore();
  const go = useGo();
  if (!sectionOn(settings, 'footer')) return null;

  const columns = settings.footerColumns;
  const mid = Math.ceil(columns.length / 2);

  const brand = (
    <div className="w-60">
      <div className="flex flex-col items-center">
        <span className="font-logo text-[34px]">Honey Layne</span>
        <p className="mt-2 whitespace-pre-line text-center font-cormorant text-[15px] font-medium text-ink">
          {settings.footerTagline}
        </p>
        <div className="mt-3 flex items-center">
          {settings.footerSocials
            .filter((s) => s.enabled)
            .map((s, i) => (
              <button
                key={i}
                type="button"
                onClick={() => s.url && go(s.url)}
                className="px-1.5 text-pink hover:text-pinkDeep"
                aria-label={s.icon}
              >
                <SocialIcon name={s.icon} size={18} />
              </button>
            ))}
        </div>
      </div>
    </div>
  );

  return (
    <footer className="relative isolate w-full overflow-hidden bg-gradient-to-b from-cream to-footerBottom">
      <FooterDecor />
      {/* Mobile: stacked + centered. */}
      <div className="flex flex-col items-center px-6 py-9 md:hidden">
        {brand}
        <div className="mt-9 flex flex-col items-center gap-7">
          {columns.map((c, i) => (
            <FooterCol key={i} column={c} center />
          ))}
        </div>
      </div>

      {/* Desktop: columns split around the centered brand. */}
      <div className="hidden flex-wrap items-start justify-between gap-x-12 gap-y-8 px-20 py-[52px] md:flex">
        {columns.slice(0, mid).map((c, i) => (
          <FooterCol key={`a${i}`} column={c} />
        ))}
        {brand}
        {columns.slice(mid).map((c, i) => (
          <FooterCol key={`b${i}`} column={c} />
        ))}
      </div>
    </footer>
  );
}
