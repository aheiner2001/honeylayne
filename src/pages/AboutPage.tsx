import { useStore } from '../store/HoneyStore';
import { sectionOn } from '../types';
import { SiteHeader } from '../components/SiteHeader';
import { SiteFooter } from '../components/SiteFooter';
import { ProductImage } from '../components/ProductImage';
import { PageDecor } from '../components/PageDecor';
import { FeatureIcon } from '../components/icons';
import { resolveSrc } from '../lib/util';

function StoryPhoto({ imageUrl }: { imageUrl: string }) {
  return (
    <div className="relative inline-block">
      <div className="rotate-[2deg] rounded bg-white p-3.5 shadow-[0_14px_24px_rgba(0,0,0,0.16)]">
        <div className="aspect-[1.05/1] w-full overflow-hidden rounded-sm">
          <ProductImage imageUrl={imageUrl} className="h-full w-full" />
        </div>
      </div>
      <div className="absolute -top-3 left-1/2 h-[26px] w-24 -translate-x-1/2 -rotate-2 bg-pinkSoft/80" />

      {/* Flowers hugging the picture frame */}
      <img
        src={resolveSrc('assets/images/deco_corner.png')}
        alt=""
        aria-hidden
        className="pointer-events-none absolute -left-12 -top-12 w-28 -scale-x-100 md:w-40"
      />
      <img
        src={resolveSrc('assets/images/deco_sprig.png')}
        alt=""
        aria-hidden
        className="pointer-events-none absolute -bottom-8 -right-6 w-16 rotate-12 md:w-24"
      />
    </div>
  );
}

export function AboutPage() {
  const { settings } = useStore();

  return (
    <div className="relative isolate min-h-screen overflow-hidden bg-blush">
      <PageDecor />
      <SiteHeader active="About" />

      {sectionOn(settings, 'about.story') && (
        <section className="px-6 py-9 md:px-20 md:py-14">
          <div className="flex flex-col items-center gap-8 md:flex-row md:items-center md:gap-10">
            <div className="flex flex-1 flex-col items-center text-center md:items-start md:text-left">
              <h1 className="font-script text-[46px] md:text-[58px]">{settings.aboutTitle}</h1>
              <p className="mt-[18px] font-cormorant text-lg font-medium text-ink">
                {settings.aboutBody1}
              </p>
              <p className="mt-3.5 font-cormorant text-lg font-medium text-ink">
                {settings.aboutBody2}
              </p>
              <p className="mt-[18px] font-script text-[30px] md:text-[34px]">
                {settings.aboutThankYou}
              </p>
            </div>
            <div className="w-full max-w-sm md:w-[40%]">
              <StoryPhoto imageUrl={settings.aboutImageUrl} />
            </div>
          </div>
        </section>
      )}

      {sectionOn(settings, 'about.features') && (
        <section className="bg-blushDeep px-6 py-9 md:px-20 md:py-12">
          <div className="flex flex-wrap justify-center gap-7 md:justify-between">
            {settings.aboutFeatures.map((f, i) => (
              <div key={i} className="flex w-[140px] flex-col items-center md:w-[200px]">
                <FeatureIcon name={f.icon} className="text-pinkDeep" size={34} />
                <p className="mt-3.5 text-center font-cormorant text-base font-medium text-ink">
                  {f.text}
                </p>
              </div>
            ))}
          </div>
        </section>
      )}

      <div className="h-9" />
      <SiteFooter />
    </div>
  );
}
