"""Renders the B4Due launcher icon (PNG fallbacks for Android < 8 and iOS).

The artwork is the same geometry as the adaptive-icon vector in
android/app/src/main/res/drawable/ic_launcher_foreground.xml: a calendar page
with a check mark, amber on the app's dark background.

    python -m pip install pillow
    python tool/generate_icons.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
BACKGROUND = (0x11, 0x13, 0x16, 255)
ACCENT = (0xF2, 0xB8, 0x4B, 255)

# Geometry in the 108-unit adaptive-icon viewport.
VIEWPORT = 108


def render(size: int, *, rounded: bool, zoom: float = 1.4) -> Image.Image:
    """[zoom] enlarges the glyph: PNG icons have no adaptive-icon safe
    zone to respect, so the glyph can fill more of the square."""
    scale = 4  # supersample for smooth edges
    s = size * scale
    u = s / VIEWPORT * zoom
    offset = (s - VIEWPORT * u) / 2
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    if rounded:
        d.rounded_rectangle((0, 0, s - 1, s - 1), radius=int(s * 0.22), fill=BACKGROUND)
    else:
        d.rectangle((0, 0, s, s), fill=BACKGROUND)

    def x(v):
        return offset + v * u

    w = int(4 * u)
    # Calendar page.
    d.rounded_rectangle((x(34), x(38), x(74), x(74)), radius=6 * u, outline=ACCENT, width=w)
    d.line((x(34), x(48), x(74), x(48)), fill=ACCENT, width=w)
    # Binder rings.
    for rx in (44, 64):
        d.line((x(rx), x(33), x(rx), x(42)), fill=ACCENT, width=w)
        for ry in (33, 42):
            r = w / 2
            d.ellipse((x(rx) - r, x(ry) - r, x(rx) + r, x(ry) + r), fill=ACCENT)
    # Check mark.
    points = [(x(43), x(60)), (x(51), x(67)), (x(66), x(53))]
    d.line(points, fill=ACCENT, width=int(4.5 * u), joint='curve')
    for px, py in (points[0], points[-1]):
        r = 4.5 * u / 2
        d.ellipse((px - r, py - r, px + r, py + r), fill=ACCENT)

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
