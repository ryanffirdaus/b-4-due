"""Renders the B4Due launcher icon (PNG fallbacks for Android < 8 and iOS).

The artwork is the same geometry as the adaptive-icon vectors in
android/app/src/main/res/drawable/ic_launcher_{background,foreground}.xml:
a white calendar card with a lime header and an ink check mark on a soft ink
to ink gradient (docs/DESIGN.md).

    python -m pip install pillow
    python tool/generate_icons.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
GRADIENT_START = (0x2A, 0x25, 0x38)  # soft ink, top left
GRADIENT_END = (0x0E, 0x0C, 0x14)  # ink (Palette.dark.background), bottom right
CARD = (0xFF, 0xFF, 0xFF, 255)
HEADER = (0xB6, 0xF3, 0x6B, 255)  # Lime (AccentColors.lime)
CHECK = (0x15, 0x12, 0x1D, 255)  # Ink (Palette.light.primary)

# Geometry in the 108-unit adaptive-icon viewport.
VIEWPORT = 108


def _gradient(s: int) -> Image.Image:
    """Diagonal linear gradient, like the vector's startX/Y=0 to endX/Y=108."""
    img = Image.new('RGBA', (s, s))
    px = img.load()
    for y in range(s):
        for x in range(s):
            t = (x + y) / (2 * (s - 1))
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(GRADIENT_START, GRADIENT_END)) + (255,)
    return img


def render(size: int, *, rounded: bool, zoom: float = 1.3) -> Image.Image:
    """[zoom] enlarges the glyph: PNG icons have no adaptive-icon safe
    zone to respect, so the glyph can fill more of the square."""
    scale = 4  # supersample for smooth edges
    s = size * scale
    u = s / VIEWPORT * zoom
    offset = (s - VIEWPORT * u) / 2

    img = _gradient(s)
    if rounded:
        mask = Image.new('L', (s, s), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, s - 1, s - 1), radius=int(s * 0.22), fill=255)
        img.putalpha(mask)
    d = ImageDraw.Draw(img)

    def x(v):
        return offset + v * u

    # Card, then the header band clipped to the card's rounded top.
    d.rounded_rectangle((x(30), x(34), x(78), x(78)), radius=8 * u, fill=CARD)
    d.rounded_rectangle((x(30), x(34), x(78), x(54)), radius=8 * u, fill=HEADER)
    d.rectangle((x(30), x(46), x(78), x(54)), fill=CARD)
    # Binder rings.
    for rx in (39, 63):
        d.rounded_rectangle((x(rx), x(28), x(rx + 6), x(40)), radius=1.5 * u, fill=CARD)
    # Check mark with round caps and joint.
    points = [(x(42), x(61)), (x(51), x(69)), (x(67), x(53))]
    w = 6 * u
    d.line(points, fill=CHECK, width=int(w), joint='curve')
    for px, py in points:
        r = w / 2
        d.ellipse((px - r, py - r, px + r, py + r), fill=CHECK)

    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    android = ROOT / 'android/app/src/main/res'
    for density, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        render(px, rounded=True).save(android / f'mipmap-{density}/ic_launcher.png')

    ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for png in ios.glob('*.png'):
        with Image.open(png) as existing:
            px = existing.size[0]
        # iOS applies its own mask and rejects transparency.
        render(px, rounded=False).convert('RGB').save(png)

    docs = ROOT / 'docs/images'
    docs.mkdir(parents=True, exist_ok=True)
    render(512, rounded=True).save(docs / 'icon-512.png')
    print('icons written')


if __name__ == '__main__':
    main()
