"""Knock out the flat neutral (checkerboard / white / gray) background that
image generators bake into "transparent" PNGs, while keeping the colorful
subject. Works because the art is saturated and the background is neutral.

Run: python3 tool/cutout.py public/assets/images/deco_bee.png
"""
import sys
from PIL import Image, ImageFilter

# A pixel is treated as background when it is bright AND near-neutral
# (R, G, B almost equal). Tinted whites/creams in the art (warm or pink)
# have a larger channel spread and are preserved.
MIN_BRIGHT = 215
MAX_SPREAD = 10


def process(path):
    rgb = Image.open(path).convert("RGB")
    w, h = rgb.size
    px = list(rgb.getdata())

    alpha = []
    for r, g, b in px:
        spread = max(r, g, b) - min(r, g, b)
        is_bg = min(r, g, b) >= MIN_BRIGHT and spread <= MAX_SPREAD
        alpha.append(0 if is_bg else 255)

    a = Image.new("L", (w, h))
    a.putdata(alpha)
    # Feather the edge ~1px so there's no hard/neutral fringe.
    a = a.filter(ImageFilter.GaussianBlur(0.8))

    out = rgb.convert("RGBA")
    out.putalpha(a)
    out.save(path)
    cleared = sum(1 for v in alpha if v == 0)
    print(f"{path}: cleared {cleared * 100 // (w * h)}% to transparent")


if __name__ == "__main__":
    process(sys.argv[1])
