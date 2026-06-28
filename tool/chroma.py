"""Chroma-key a solid green-screen background to transparent, with green-spill
cleanup. Use for flat art that contains white/light parts (e.g. bee wings)
that a neutral-background cutout would wrongly erase.

Run: python3 tool/chroma.py src_green.png out.png
"""
import sys
from PIL import Image, ImageFilter


def process(src, dst):
    rgb = Image.open(src).convert("RGB")
    w, h = rgb.size
    px = list(rgb.getdata())

    out_px = []
    alpha = []
    for r, g, b in px:
        green_excess = g - max(r, b)
        is_bg = g > 90 and green_excess > 40
        alpha.append(0 if is_bg else 255)
        # De-spill: pull down green halo on kept edge pixels.
        if not is_bg and green_excess > 12:
            g = max(r, b) + 12
        out_px.append((r, g, b))

    keyed = Image.new("RGB", (w, h))
    keyed.putdata(out_px)

    a = Image.new("L", (w, h))
    a.putdata(alpha)
    a = a.filter(ImageFilter.GaussianBlur(0.8))

    result = keyed.convert("RGBA")
    result.putalpha(a)
    result.save(dst)
    cleared = sum(1 for v in alpha if v == 0)
    print(f"{dst}: cleared {cleared * 100 // (w * h)}% to transparent")


if __name__ == "__main__":
    process(sys.argv[1], sys.argv[2])
