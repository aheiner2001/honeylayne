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
