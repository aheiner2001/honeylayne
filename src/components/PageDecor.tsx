import { resolveSrc } from '../lib/util';

const corner = resolveSrc('assets/images/deco_corner.png');
const sprig = resolveSrc('assets/images/deco_sprig.png');

/** Floral layer for the storefront pages, tucked behind the content (-z-10)
 * in the blush margins. Bees live only in the header + footer.
 *
 * `sprigs` controls the small floating flowers; turn them off on dense pages
 * (e.g. the shop grid) where they look out of place. */
export function PageDecor({ sprigs = true }: { sprigs?: boolean }) {
  return (
    <div aria-hidden className="pointer-events-none absolute inset-0 -z-10 overflow-hidden">
      <img
        src={corner}
        alt=""
        className="absolute -left-10 -top-8 w-40 opacity-80 md:w-64"
      />
      <img
        src={corner}
        alt=""
        className="absolute -bottom-12 -right-12 w-44 rotate-180 opacity-70 md:w-72"
      />
      {sprigs && (
        <>
          <img
            src={sprig}
            alt=""
            className="absolute right-[3%] top-[42%] w-16 rotate-6 opacity-75 md:w-24"
          />
          <img
            src={sprig}
            alt=""
            className="absolute bottom-[7%] left-[12%] hidden w-14 -rotate-12 opacity-70 lg:block"
          />
        </>
      )}
    </div>
  );
}
