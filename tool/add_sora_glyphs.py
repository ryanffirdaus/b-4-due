"""Adds glyphs the app needs that Sora lacks to the vendored Sora fonts.

Sora has no "≈" (U+2248), which the app shows in prices such as
"US$20,00 ≈ Rp 357.611". It is built from two of Sora's own tildes, so it
matches every weight. Sora's OFL declares no Reserved Font Name, so a
modified copy may keep the name.

    python -m pip install fonttools
    python tool/add_sora_glyphs.py

Running it again is harmless: fonts that already have the glyph are left
alone.
"""

from pathlib import Path

from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

FONTS = Path(__file__).resolve().parent.parent / "assets" / "fonts"
APPROX = 0x2248
NAME = "approxequal"


def add_approx(path: Path) -> bool:
    font = TTFont(path)
    cmap = font.getBestCmap()
    if APPROX in cmap:
        return False

    tilde = cmap[ord("~")]
    glyph_set = font.getGlyphSet()
    glyf = font["glyf"]
    box = glyf[tilde]
    box.recalcBounds(glyf)
    # Two tildes, one above and one below the tilde's own centre line.
    gap = (box.yMax - box.yMin) * 0.95

    pen = TTGlyphPen(glyph_set)
    for dy in (gap / 2, -gap / 2):
        glyph_set[tilde].draw(TransformPen(pen, (1, 0, 0, 1, 0, round(dy))))

    font.setGlyphOrder(font.getGlyphOrder() + [NAME])
    glyf[NAME] = pen.glyph()
    font["hmtx"][NAME] = font["hmtx"][tilde]
    for table in font["cmap"].tables:
        if table.isUnicode():
            table.cmap[APPROX] = NAME
    font.save(path)
    return True


def main() -> None:
    for path in sorted(FONTS.glob("Sora-*.ttf")):
        print(f"{path.name}: {'added' if add_approx(path) else 'already there'}")


if __name__ == "__main__":
    main()
