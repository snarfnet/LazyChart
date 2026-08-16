#!/usr/bin/env python3
"""Generate the app icon: friendly bar chart on a blue rounded background."""
from PIL import Image, ImageDraw

S = 1024
img = Image.new('RGB', (S, S), (76, 110, 245))  # accent blue

d = ImageDraw.Draw(img)

# soft vertical gradient
for y in range(S):
    k = y / S
    r = int(76 + (46 - 76) * k)
    g = int(110 + (72 - 110) * k)
    b = int(245 + (200 - 245) * k)
    d.line([(0, y), (S, y)], fill=(r, g, b))

# baseline
margin = 235
base_y = S - margin
d.rounded_rectangle([margin, base_y - 6, S - margin, base_y + 6], radius=6, fill=(255, 255, 255))

# bars (rising) with a couple of accent colors
bars = [
    (0.30, (255, 212, 59)),   # yellow
    (0.52, (81, 207, 102)),   # green
    (0.72, (255, 255, 255)),  # white
    (0.95, (240, 101, 149)),  # pink
]
n = len(bars)
avail = (S - 2 * margin)
gap = 34
bw = (avail - gap * (n - 1)) / n
x = margin
max_h = base_y - margin
for frac, col in bars:
    h = max_h * frac
    top = base_y - h
    d.rounded_rectangle([x, top, x + bw, base_y], radius=22, fill=col)
    x += bw + gap

# trend line over the bars
pts = []
x = margin + bw / 2
for frac, _ in bars:
    h = max_h * frac
    pts.append((x, base_y - h - 46))
    x += bw + gap
d.line(pts, fill=(255, 255, 255), width=14, joint='curve')
for p in pts:
    d.ellipse([p[0] - 16, p[1] - 16, p[0] + 16, p[1] + 16], fill=(255, 255, 255))

# rounded mask (iOS applies its own mask, but keep square per guidelines)
out = 'LazyChart/Assets.xcassets/AppIcon.appiconset/icon_1024.png'
img.save(out)
print('wrote', out)
