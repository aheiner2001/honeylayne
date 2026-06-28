"""Flood-fill the outer white background of a PNG to transparent.

Starts from the four corners so interior whites (petals, wings, dress)
are preserved. Run: python3 tool/make_transparent.py in.png out.png [thresh]
"""
import sys
from PIL import Image, ImageDraw, ImageFilter

SEED = (255, 0, 255)


def process(src: str, dst: str, thresh: int = 45) -> None:
    img = Image.open(src).convert("RGB")
    w, h = img.size
    for corner in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        ImageDraw.floodfill(img, corner, SEED, thresh=thresh)

    pixels = list(img.getdata())
    alpha_vals = []
    for p in pixels:
        if p == SEED:
            alpha_vals.append(0)
            continue
        r, g, b = p
        # Knock out leftover near-white, low-saturation blobs (interior white
        # blossoms) so they blend into the page instead of showing as boxes.
        if min(r, g, b) >= 244 and (max(r, g, b) - min(r, g, b)) <= 12:
            alpha_vals.append(0)
        else:
            alpha_vals.append(255)
    alpha = Image.new("L", (w, h))
    alpha.putdata(alpha_vals)
    # Soften the cut edge by 1px so there's no hard white fringe.
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.8))

    out = Image.open(src).convert("RGBA")
    out.putalpha(alpha)
    out.save(dst)
    print(f"wrote {dst}")


if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    t = int(sys.argv[3]) if len(sys.argv) > 3 else 45
    process(src, dst, t)
