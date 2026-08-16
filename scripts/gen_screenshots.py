#!/usr/bin/env python3
"""Generate App Store marketing screenshots with PIL.
Draws real-looking bar/pie/line charts inside a phone-style card plus a headline.
Outputs iPhone 6.7" (1290x2796) and iPad 12.9" (2048x2732)."""
import os, math
from PIL import Image, ImageDraw, ImageFont

BG_TOP = (76, 110, 245)
BG_BOT = (46, 72, 200)
CARD = (255, 255, 255)
INK = (28, 33, 48)
SUB = (110, 120, 140)
PAL = [(76, 110, 245), (255, 212, 59), (81, 207, 102), (240, 101, 149), (132, 94, 247)]

FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
    "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]


def font(size, bold=False):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()


def gradient(w, h):
    img = Image.new('RGB', (w, h), BG_TOP)
    d = ImageDraw.Draw(img)
    for y in range(h):
        k = y / h
        r = int(BG_TOP[0] + (BG_BOT[0] - BG_TOP[0]) * k)
        g = int(BG_TOP[1] + (BG_BOT[1] - BG_TOP[1]) * k)
        b = int(BG_TOP[2] + (BG_BOT[2] - BG_TOP[2]) * k)
        d.line([(0, y), (w, y)], fill=(r, g, b))
    return img


def center_text(d, cx, y, text, fnt, fill):
    bb = d.textbbox((0, 0), text, font=fnt)
    d.text((cx - (bb[2] - bb[0]) / 2, y), text, font=fnt, fill=fill)


def rounded_card(d, box, radius, fill):
    d.rounded_rectangle(box, radius=radius, fill=fill)


def draw_bar(d, box, labels, series_vals):
    x0, y0, x1, y1 = box
    base = y1 - 8
    top = y0 + 10
    n = len(labels)
    groups = len(series_vals)
    mx = max(max(s) for s in series_vals) or 1
    gap = (x1 - x0) * 0.04
    gw = (x1 - x0 - gap * (n + 1)) / n
    bw = gw / groups
    for gi in range(n):
        gx = x0 + gap + gi * (gw + gap)
        for si in range(groups):
            v = series_vals[si][gi]
            h = (base - top) * (v / mx)
            bx = gx + si * bw
            col = PAL[si % len(PAL)]
            d.rounded_rectangle([bx, base - h, bx + bw - 4, base], radius=8, fill=col)


def draw_pie(d, box, vals):
    x0, y0, x1, y1 = box
    s = min(x1 - x0, y1 - y0)
    cx = (x0 + x1) / 2
    cy = (y0 + y1) / 2
    r = s / 2 - 6
    total = sum(vals) or 1
    a = -90
    for i, v in enumerate(vals):
        sweep = 360 * v / total
        d.pieslice([cx - r, cy - r, cx + r, cy + r], a, a + sweep,
                   fill=PAL[i % len(PAL)])
        a += sweep
    d.ellipse([cx - r * 0.42, cy - r * 0.42, cx + r * 0.42, cy + r * 0.42], fill=CARD)


def draw_line(d, box, series_vals):
    x0, y0, x1, y1 = box
    base = y1 - 8
    top = y0 + 10
    n = len(series_vals[0])
    mx = max(max(s) for s in series_vals) or 1
    step = (x1 - x0) / (n - 1) if n > 1 else 0
    for si, s in enumerate(series_vals):
        pts = []
        for i, v in enumerate(s):
            x = x0 + step * i
            y = base - (base - top) * (v / mx)
            pts.append((x, y))
        col = PAL[si % len(PAL)]
        if len(pts) > 1:
            d.line(pts, fill=col, width=8, joint='curve')
        for p in pts:
            d.ellipse([p[0] - 9, p[1] - 9, p[0] + 9, p[1] + 9], fill=col)


def make(w, h, headline_ja, headline_en, kind, out):
    img = gradient(w, h)
    d = ImageDraw.Draw(img)
    pad = int(w * 0.08)
    center_text(d, w / 2, int(h * 0.055), headline_ja, font(int(w * 0.062), True), (255, 255, 255))
    center_text(d, w / 2, int(h * 0.115), headline_en, font(int(w * 0.032)), (215, 225, 255))

    cy0 = int(h * 0.20)
    cy1 = int(h * 0.74)
    card = [pad, cy0, w - pad, cy1]
    rounded_card(d, card, int(w * 0.06), CARD)

    inner = [card[0] + int(w * 0.06), card[1] + int(h * 0.06),
             card[2] - int(w * 0.06), card[1] + int(h * 0.06) + int((cy1 - cy0) * 0.52)]

    labels = ['Q1', 'Q2', 'Q3', 'Q4']
    if kind == 'bar':
        draw_bar(d, inner, labels, [[42, 65, 58, 90], [30, 48, 70, 62]])
    elif kind == 'pie':
        draw_pie(d, inner, [42, 30, 18, 10])
    else:
        draw_line(d, inner, [[30, 52, 45, 88], [20, 35, 60, 72]])

    # mini data table under the chart
    ty = inner[3] + int(h * 0.03)
    tx = card[0] + int(w * 0.08)
    fnt = font(int(w * 0.032))
    rows = [('Label', '売上', '費用'), ('Q1', '42', '30'), ('Q2', '65', '48'), ('Q3', '58', '70')]
    colw = (card[2] - card[0] - int(w * 0.16)) / 3
    for ri, row in enumerate(rows):
        yy = ty + ri * int(h * 0.038)
        if ri == 0:
            d.rounded_rectangle([tx - 12, yy - 6, card[2] - int(w * 0.06), yy + int(h * 0.033)],
                                radius=8, fill=(238, 242, 255))
        for ci, cell in enumerate(row):
            d.text((tx + ci * colw, yy), cell, font=fnt, fill=INK if ci == 0 or ri == 0 else SUB)

    img.save(out)
    print('wrote', out)


def main():
    os.makedirs('shots/iphone', exist_ok=True)
    os.makedirs('shots/ipad', exist_ok=True)
    IW, IH = 1290, 2796
    make(IW, IH, 'エクセルいらず', 'A clean chart in seconds', 'bar', 'shots/iphone/1.png')
    make(IW, IH, '円グラフもワンタップ', 'Bar, line and pie', 'pie', 'shots/iphone/2.png')
    make(IW, IH, '数字を入れるだけ', 'Type numbers or paste CSV', 'line', 'shots/iphone/3.png')
    PW, PH = 2048, 2732
    make(PW, PH, 'エクセルいらず', 'A clean chart in seconds', 'bar', 'shots/ipad/1.png')


if __name__ == '__main__':
    main()
