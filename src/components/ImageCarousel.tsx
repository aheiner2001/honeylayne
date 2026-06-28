import { useRef, useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

import { ProductImage } from './ProductImage';

/** Swipeable image gallery with dot indicators. Falls back to a single image
 * (no dots/arrows) when there's only one. Tapping calls `onImageClick` unless
 * the touch was a swipe. */
export function ImageCarousel({
  images,
  className,
  objectFit = 'cover',
  showArrows = false,
  onImageClick,
}: {
  images: string[];
  className?: string;
  objectFit?: 'cover' | 'contain';
  showArrows?: boolean;
  onImageClick?: () => void;
}) {
  const slides = images.length > 0 ? images : [''];
  const [index, setIndex] = useState(0);
  const start = useRef<{ x: number; y: number } | null>(null);
  const moved = useRef(false);

  const clamp = (i: number) => Math.max(0, Math.min(slides.length - 1, i));
  const go = (i: number) => setIndex(clamp(i));

  const onTouchStart = (e: React.TouchEvent) => {
    start.current = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    moved.current = false;
  };
  const onTouchMove = (e: React.TouchEvent) => {
    if (!start.current) return;
    const dx = e.touches[0].clientX - start.current.x;
    const dy = e.touches[0].clientY - start.current.y;
    if (Math.abs(dx) > 8 && Math.abs(dx) > Math.abs(dy)) moved.current = true;
  };
  const onTouchEnd = (e: React.TouchEvent) => {
    if (!start.current) return;
    const dx = e.changedTouches[0].clientX - start.current.x;
    if (Math.abs(dx) > 40) {
      go(index + (dx < 0 ? 1 : -1));
    } else if (!moved.current) {
      onImageClick?.();
    }
    start.current = null;
  };

  return (
    <div className={`relative overflow-hidden ${className ?? ''}`}>
      <div
        className="flex h-full w-full transition-transform duration-300 ease-out"
        style={{ transform: `translateX(-${index * 100}%)` }}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onClick={() => {
          if (!moved.current) onImageClick?.();
        }}
        role={onImageClick ? 'button' : undefined}
      >
        {slides.map((src, i) => (
          <div key={i} className="h-full w-full shrink-0">
            <ProductImage imageUrl={src} objectFit={objectFit} className="h-full w-full" />
          </div>
        ))}
      </div>

      {showArrows && slides.length > 1 && (
        <>
          <button
            type="button"
            aria-label="Previous image"
            onClick={(e) => {
              e.stopPropagation();
              go(index - 1);
            }}
            className={`absolute left-2 top-1/2 -translate-y-1/2 flex h-8 w-8 items-center justify-center rounded-full bg-white/75 text-pinkDeep shadow-sm transition-opacity hover:bg-white ${
              index === 0 ? 'pointer-events-none opacity-0' : 'opacity-100'
            }`}
          >
            <ChevronLeft size={18} />
          </button>
          <button
            type="button"
            aria-label="Next image"
            onClick={(e) => {
              e.stopPropagation();
              go(index + 1);
            }}
            className={`absolute right-2 top-1/2 -translate-y-1/2 flex h-8 w-8 items-center justify-center rounded-full bg-white/75 text-pinkDeep shadow-sm transition-opacity hover:bg-white ${
              index === slides.length - 1 ? 'pointer-events-none opacity-0' : 'opacity-100'
            }`}
          >
            <ChevronRight size={18} />
          </button>
        </>
      )}

      {slides.length > 1 && (
        <div className="pointer-events-none absolute inset-x-0 bottom-2 flex items-center justify-center gap-1.5">
          {slides.map((_, i) => (
            <button
              key={i}
              type="button"
              aria-label={`Go to image ${i + 1}`}
              onClick={(e) => {
                e.stopPropagation();
                go(i);
              }}
              className={`pointer-events-auto h-1.5 rounded-full transition-all ${
                i === index ? 'w-4 bg-pinkDeep' : 'w-1.5 bg-white/80 shadow-sm'
              }`}
            />
          ))}
        </div>
      )}
    </div>
  );
}
