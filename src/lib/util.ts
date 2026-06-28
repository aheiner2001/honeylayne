/** Resolve an image reference (asset path, http url, or data uri) to a usable src. */
export function resolveSrc(url: string): string {
  if (!url) return '';
  if (url.startsWith('data:') || url.startsWith('http')) return url;
  if (url.startsWith('/')) return url;
  // e.g. "assets/images/bees_trail.png" -> served from /assets/images/...
  return `/${url}`;
}

/** Open an external link in a new tab. */
export function openExternal(url: string): void {
  if (!url) return;
  window.open(url, '_blank', 'noopener,noreferrer');
}

/** Join class names, skipping falsy values. */
export function cx(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ');
}

async function decodeImage(file: File): Promise<ImageBitmap | HTMLImageElement> {
  if (typeof createImageBitmap === 'function') {
    try {
      return await createImageBitmap(file);
    } catch {
      /* fall back to <img> below (some formats/browsers) */
    }
  }
  return await new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = (e) => {
      URL.revokeObjectURL(url);
      reject(e);
    };
    img.src = url;
  });
}

/**
 * Normalize a user-selected photo before upload: decode it, downscale to a
 * sensible max dimension, and re-encode as JPEG. This converts iPhone HEIC
 * photos (which Chrome/Android can't display) into a universally-viewable
 * format and keeps file sizes small. Falls back to the original file if the
 * browser can't decode it. */
export async function prepareImageForUpload(
  file: File,
  maxDim = 1600,
  quality = 0.85,
): Promise<File> {
  try {
    const source = await decodeImage(file);
    const w0 = (source as ImageBitmap).width;
    const h0 = (source as ImageBitmap).height;
    if (!w0 || !h0) return file;

    const scale = Math.min(1, maxDim / Math.max(w0, h0));
    const w = Math.max(1, Math.round(w0 * scale));
    const h = Math.max(1, Math.round(h0 * scale));

    const canvas = document.createElement('canvas');
    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext('2d');
    if (!ctx) return file;
    ctx.drawImage(source as CanvasImageSource, 0, 0, w, h);
    if ('close' in source && typeof source.close === 'function') source.close();

    const blob = await new Promise<Blob | null>((res) =>
      canvas.toBlob(res, 'image/jpeg', quality),
    );
    if (!blob) return file;

    const base = file.name.replace(/\.[^.]+$/, '') || 'photo';
    return new File([blob], `${base}.jpg`, { type: 'image/jpeg' });
  } catch {
    return file;
  }
}
