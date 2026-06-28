import { Mail, Camera, Phone, type LucideProps } from 'lucide-react';
import type { ComponentType } from 'react';

import { useStore } from '../store/HoneyStore';
import { sectionOn } from '../types';
import { SiteHeader } from '../components/SiteHeader';
import { SiteFooter } from '../components/SiteFooter';
import { PageDecor } from '../components/PageDecor';
import { openExternal } from '../lib/util';

function ContactRow({
  Icon,
  label,
  onClick,
}: {
  Icon: ComponentType<LucideProps>;
  label: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="my-2 flex items-center gap-3 rounded-full bg-white/60 px-[22px] py-3.5"
    >
      <Icon className="text-pink" size={20} />
      <span className="font-cormorant text-[17px] font-semibold text-pinkDeep">{label}</span>
    </button>
  );
}

export function ContactPage() {
  const { settings } = useStore();

  return (
    <div className="relative isolate min-h-screen overflow-hidden bg-blush">
      <PageDecor />
      <SiteHeader active="Contact" />

      {sectionOn(settings, 'contact.details') && (
        <section className="px-6 py-10 md:py-16">
          <div className="mx-auto flex max-w-[560px] flex-col items-center">
            <h1 className="text-center font-script text-[46px] md:text-[60px]">
              {settings.contactTitle}
            </h1>
            <p className="mt-3.5 text-center font-cormorant text-lg font-medium text-ink">
              {settings.contactBlurb}
            </p>
            <div className="mt-7 flex flex-col items-center">
              {settings.contactEmail && (
                <ContactRow
                  Icon={Mail}
                  label={settings.contactEmail}
                  onClick={() => openExternal(`mailto:${settings.contactEmail}`)}
                />
              )}
              {settings.contactInstagram && (
                <ContactRow
                  Icon={Camera}
                  label="Instagram"
                  onClick={() => openExternal(settings.contactInstagram)}
                />
              )}
              {settings.contactPhone && (
                <ContactRow
                  Icon={Phone}
                  label={settings.contactPhone}
                  onClick={() => openExternal(`tel:${settings.contactPhone}`)}
                />
              )}
            </div>
          </div>
        </section>
      )}

      <div className="h-9" />
      <SiteFooter />
    </div>
  );
}
