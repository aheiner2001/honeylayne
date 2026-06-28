import { useState } from 'react';
import { Flower2 } from 'lucide-react';

import { resolveSrc } from '../lib/util';

/** Renders an image from an asset path, http url, or data uri, with a soft
 * placeholder while empty or on error. */
export function ProductImage({
  imageUrl,
  className,
  objectFit = 'cover',
}: {
  imageUrl: string;
  className?: string;
  objectFit?: 'cover' | 'contain';
}) {
  const [errored, setErrored] = useState(false);
  const src = resolveSrc(imageUrl);

  if (!src || errored) {
    return (
      <div
        className={`flex items-center justify-center bg-blushDeep ${className ?? ''}`}
      >
        <Flower2 className="text-pinkSoft" size={40} />
      </div>
    );
  }

  return (
    <img
      src={src}
      alt=""
      loading="lazy"
      onError={() => setErrored(true)}
      className={`${objectFit === 'cover' ? 'object-cover' : 'object-contain'} ${className ?? ''}`}
    />
  );
}
