#!/usr/bin/env python3
"""Compose the five store-listing screenshots for Wash Quote & Invoice.

Why this exists (2026-09-18):
  The definitive path is `integration_test/store_shots_test.dart`, but the
  factory's currently-installed Flutter (3.35.2 / Dart 3.9.0) is behind the
  app's pubspec pin (`flutter: >=3.47.4 <3.48.0`, Dart ^3.13.0). Until the
  founder installs the pinned Flutter and reruns the drive target, this
  script produces store-sized PNGs of the actual app's design tokens
  (Cupertino chrome, accent #0a6ea8, DESIGN_GUIDE spacing) with the exact
  seed data from `store_shots_test.dart::_seedStoreShotData` drawn in.

  Once the Dart driver can run, delete this script and swap in the driver
  output — see `RELEASE_CHECKLIST.md` Reshoot Store Screenshots.

Output:
  store/ios/en-US/screenshots/    at 1320 x 2868  (App Store 6.9" / iPhone 16 Pro Max)
  store/android/en-US/screenshots/ at 1080 x 2400 (Play required minimum)

Both stories match spec §9:
  01_jobs.png            — Jobs home: hero card, waiting cards, accepted list.
  02_quote_builder.png   — Quote builder: 2 line items, before-photo strip, total.
  03_job_detail.png      — PDF preview (logo, lines, deposit, pay-via, photos).
  04_money.png           — This month totals: Quoted / Accepted / Invoiced / Paid.
  05_services.png        — Six starter services with unit prices.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]  # apps/wash-quote
IOS_OUT = ROOT / "store" / "ios" / "en-US" / "screenshots"
ANDROID_OUT = ROOT / "store" / "android" / "en-US" / "screenshots"

ACCENT = (10, 110, 168)          # #0a6ea8
ACCENT_DARK = (7, 84, 128)
INK = (28, 28, 30)
SUBINK = (110, 110, 115)
HAIR = (229, 229, 234)
BG = (255, 255, 255)
CHIP = (242, 242, 247)
DIVIDER = (242, 242, 247)


@dataclass
class Size:
    w: int
    h: int
    tab_bar_h: int
    status_bar_h: int
    home_indicator_h: int
    label: str  # "ios" or "android"


IOS_SIZE = Size(1320, 2868, tab_bar_h=170, status_bar_h=132, home_indicator_h=34, label="ios")
ANDROID_SIZE = Size(1080, 2400, tab_bar_h=180, status_bar_h=96, home_indicator_h=48, label="android")


def _find_font(bold: bool, size: int) -> ImageFont.FreeTypeFont:
    candidates_bold = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
    ]
    candidates_reg = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    picks = candidates_bold if bold else candidates_reg
    for p in picks:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return _find_font(bold=bold, size=size)


def draw_status_bar(img: Image.Image, s: Size) -> None:
    d = ImageDraw.Draw(img)
    # Time top-left, battery/signal top-right — kept minimal so the app pixels dominate.
    time_font = font(44, bold=True)
    d.text((60, s.status_bar_h // 2 - 22), "9:41", fill=INK, font=time_font)
    # Fake battery/signal glyphs — three dots + a battery outline.
    right = s.w - 60
    for i, r in enumerate([6, 8, 10]):
        cx = right - 90 - i * 26
        cy = s.status_bar_h // 2
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=INK)
    # battery
    bx = right - 60
    by = s.status_bar_h // 2
    d.rectangle((bx, by - 14, bx + 46, by + 14), outline=INK, width=3)
    d.rectangle((bx + 4, by - 10, bx + 42, by + 10), fill=INK)
    d.rectangle((bx + 46, by - 6, bx + 50, by + 6), fill=INK)


def draw_home_indicator(img: Image.Image, s: Size) -> None:
    if s.label != "ios":
        return
    d = ImageDraw.Draw(img)
    w = 360
    h = 10
    x = (s.w - w) // 2
    y = s.h - s.home_indicator_h + 8
    d.rounded_rectangle((x, y, x + w, y + h), radius=5, fill=INK)


def draw_tab_bar(img: Image.Image, s: Size, selected: int) -> None:
    d = ImageDraw.Draw(img)
    y0 = s.h - s.home_indicator_h - s.tab_bar_h
    d.rectangle((0, y0, s.w, s.h - s.home_indicator_h), fill=BG)
    d.line((0, y0, s.w, y0), fill=HAIR, width=2)

    labels = ["Jobs", "Customers", "Services", "Money"]
    slot = s.w / 4
    label_font = font(28, bold=True)
    for i, label in enumerate(labels):
        cx = int(slot * i + slot / 2)
        cy = y0 + s.tab_bar_h // 2 - 20
        color = ACCENT if i == selected else SUBINK
        # Simple icon glyph: a rounded square with a hint of shape.
        _draw_tab_icon(d, i, cx, cy - 20, color)
        # Text
        tw = d.textlength(label, font=label_font)
        d.text((cx - tw / 2, cy + 24), label, fill=color, font=label_font)


def _draw_tab_icon(d: ImageDraw.ImageDraw, index: int, cx: int, cy: int, color: tuple) -> None:
    # Ultra-simple line-style glyphs — the design goal is "recognizable tab
    # bar shape at thumbnail size", not pixel-perfect SF Symbols.
    sz = 36
    if index == 0:  # home
        d.polygon(
            [(cx - sz, cy + 6), (cx, cy - sz), (cx + sz, cy + 6),
             (cx + sz - 4, cy + sz), (cx - sz + 4, cy + sz)],
            outline=color, width=4)
    elif index == 1:  # person
        d.ellipse((cx - 16, cy - 26, cx + 16, cy - 4), outline=color, width=4)
        d.arc((cx - 26, cy - 4, cx + 26, cy + 42), start=180, end=360, fill=color, width=4)
    elif index == 2:  # pencil
        d.line((cx - 22, cy + 22, cx + 22, cy - 22), fill=color, width=4)
        d.polygon([(cx + 22, cy - 22), (cx + 30, cy - 20), (cx + 20, cy - 30)], outline=color, width=3)
    else:  # clock
        d.ellipse((cx - 22, cy - 22, cx + 22, cy + 22), outline=color, width=4)
        d.line((cx, cy, cx, cy - 14), fill=color, width=4)
        d.line((cx, cy, cx + 10, cy + 4), fill=color, width=4)


def draw_header(img: Image.Image, s: Size, title: str, y: int) -> int:
    d = ImageDraw.Draw(img)
    title_font = font(64, bold=True)
    tw = d.textlength(title, font=title_font)
    d.text(((s.w - tw) / 2, y), title, fill=INK, font=title_font)
    return y + 90


def rounded_rect(d: ImageDraw.ImageDraw, box, radius: int, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


# ---------- Screen 1: Jobs ----------
def render_jobs(s: Size) -> Image.Image:
    img = Image.new("RGB", (s.w, s.h), BG)
    d = ImageDraw.Draw(img)
    draw_status_bar(img, s)

    y = s.status_bar_h + 40
    # Large-title header row: "Jobs" left, segmented control right.
    title_font = font(80, bold=True)
    d.text((60, y), "Jobs", fill=INK, font=title_font)
    seg_w = 520
    seg_h = 80
    seg_x = s.w - 60 - seg_w
    seg_y = y + 12
    rounded_rect(d, (seg_x, seg_y, seg_x + seg_w, seg_y + seg_h), 20, fill=CHIP)
    # Selected pill "Quotes"
    rounded_rect(d, (seg_x + 8, seg_y + 8, seg_x + seg_w // 2 - 4, seg_y + seg_h - 8),
                 16, fill=(255, 255, 255))
    seg_font = font(30, bold=True)
    d.text((seg_x + 88, seg_y + 24), "Quotes", fill=INK, font=seg_font)
    d.text((seg_x + seg_w // 2 + 60, seg_y + 24), "Invoices", fill=SUBINK, font=seg_font)

    y += 160

    # Hero card
    hero_h = 380
    hero_box = (60, y, s.w - 60, y + hero_h)
    rounded_rect(d, hero_box, 44, fill=ACCENT)
    # subtle circle highlight (right side)
    circle_r = 260
    hi = Image.new("RGBA", (circle_r * 2, circle_r * 2), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hi)
    hd.ellipse((0, 0, circle_r * 2, circle_r * 2), fill=(255, 255, 255, 30))
    img.paste(hi, (s.w - 60 - circle_r, y - 60), hi)

    # camera glyph disc — RGBA-composite so the translucent white shows
    # over the accent card without going opaque.
    disc_x, disc_y, disc_r = 120, y + 80, 44
    disc = Image.new("RGBA", (disc_r * 2 + 4, disc_r * 2 + 4), (0, 0, 0, 0))
    dd = ImageDraw.Draw(disc)
    dd.ellipse((2, 2, disc_r * 2 + 2, disc_r * 2 + 2), fill=(255, 255, 255, 80))
    img.paste(disc, (disc_x - disc_r - 2, disc_y - disc_r - 2), disc)
    _draw_camera_glyph(d, disc_x, disc_y, color=(255, 255, 255))

    hero_head = font(56, bold=True)
    hero_sub = font(34)
    d.text((120, y + 180), "New quote from the driveway",
           fill=(255, 255, 255), font=hero_head)
    d.text((120, y + 254),
           "Snap the surface, pick a service, send the PDF",
           fill=(240, 245, 250), font=hero_sub)

    y += hero_h + 60

    # Waiting on the customer — section header
    section_font = font(38, bold=True)
    meta_font = font(26)
    d.text((60, y), "Waiting on the customer", fill=INK, font=section_font)
    d.text((60, y + 56), "3  ·  $2,192.00", fill=SUBINK, font=meta_font)
    y += 120

    # Horizontal row of 3 quote cards
    card_w, card_h = 380, 460
    gap = 40
    cards = [
        ("House soft wash · 2,400 sq ft", "Maria Okafor · $1,600.00", "Sent 2d ago", (150, 190, 220)),
        ("Driveway · 900 sq ft", "Jimmy Alvarez · $292.00", "Sent 4d ago", (180, 200, 190)),
        ("Fence · 180 lin ft", "Priya Patel · $720.00", "Sent 1d ago", (200, 180, 160)),
    ]
    for i, (line, sub, pill, tint) in enumerate(cards):
        cx = 60 + i * (card_w + gap)
        rounded_rect(d, (cx, y, cx + card_w, y + card_h), 28, fill=CHIP)
        # photo area (top 60%)
        photo_h = 260
        rounded_rect(d, (cx, y, cx + card_w, y + photo_h), 28, fill=tint)
        # Simulated house/surface hint: darker rectangle band across bottom of "photo".
        d.rectangle((cx, y + photo_h - 60, cx + card_w, y + photo_h), fill=(80, 90, 100))
        # status pill
        pill_font = font(22, bold=True)
        pw = d.textlength(pill, font=pill_font) + 40
        ph = 42
        pill_box = (cx + 20, y + photo_h - 60, cx + 20 + pw, y + photo_h - 60 + ph)
        rounded_rect(d, pill_box, 21, fill=(0, 0, 0, 180))
        d.text((cx + 40, y + photo_h - 60 + 8), pill, fill=(255, 255, 255), font=pill_font)
        # text
        d.text((cx + 20, y + photo_h + 24), line, fill=INK, font=font(26, bold=True))
        d.text((cx + 20, y + photo_h + 70), sub, fill=SUBINK, font=font(24))

    y += card_h + 80

    # Accepted this week
    d.text((60, y), "Accepted this week", fill=INK, font=section_font)
    d.text((60, y + 56), "2  ·  $1,455.00", fill=SUBINK, font=meta_font)
    y += 120

    for label, price in [
        ("Commercial flatwork · Marcus Chen", "$900.00"),
        ("House soft wash · Sarah Vaughn", "$555.00"),
    ]:
        row_h = 90
        d.ellipse((70, y + row_h // 2 - 10, 90, y + row_h // 2 + 10), fill=ACCENT)
        d.text((120, y + 22), label, fill=INK, font=font(30, bold=False))
        pw = d.textlength(price, font=font(32, bold=True))
        d.text((s.w - 60 - pw, y + 20), price, fill=INK, font=font(32, bold=True))
        y += row_h
        d.line((60, y, s.w - 60, y), fill=DIVIDER, width=2)

    draw_tab_bar(img, s, selected=0)
    draw_home_indicator(img, s)
    return img


def _draw_camera_glyph(d: ImageDraw.ImageDraw, cx: int, cy: int, color) -> None:
    # Simplified camera: body + lens
    body = (cx - 30, cy - 18, cx + 30, cy + 22)
    d.rounded_rectangle(body, radius=6, outline=color, width=4)
    d.rectangle((cx - 10, cy - 28, cx + 10, cy - 18), outline=color, width=4)
    d.ellipse((cx - 12, cy - 6, cx + 12, cy + 18), outline=color, width=4)


# ---------- Screen 2: Quote builder ----------
def render_builder(s: Size) -> Image.Image:
    img = Image.new("RGB", (s.w, s.h), BG)
    d = ImageDraw.Draw(img)
    draw_status_bar(img, s)

    # Nav bar with back chevron + title
    y = s.status_bar_h + 20
    d.polygon([(90, y + 40), (60, y + 70), (90, y + 100)], outline=ACCENT, width=6)
    d.text((120, y + 40),  "Jobs", fill=ACCENT, font=font(32))
    title_font = font(56, bold=True)
    tw = d.textlength("New quote", font=title_font)
    d.text(((s.w - tw) / 2, y + 30), "New quote", fill=INK, font=title_font)
    y += 160

    # Customer row
    d.text((60, y), "Customer", fill=SUBINK, font=font(24, bold=True))
    y += 40
    row_h = 100
    rounded_rect(d, (60, y, s.w - 60, y + row_h), 20, fill=CHIP)
    d.text((90, y + 28), "Maria Okafor", fill=INK, font=font(34, bold=True))
    d.text((s.w - 90 - d.textlength("Change", font=font(28)), y + 32), "Change", fill=ACCENT, font=font(28))
    y += row_h + 40

    # Service lines
    d.text((60, y), "Service lines", fill=SUBINK, font=font(24, bold=True))
    y += 40

    lines = [
        ("House soft wash", "2,400 · $0.30", "$720.00"),
        ("Roof",            "1,600 · $0.55", "$880.00"),
    ]
    for name, sub, total in lines:
        rounded_rect(d, (60, y, s.w - 60, y + 140), 20, fill=BG, outline=HAIR, width=2)
        d.text((90, y + 24), name, fill=INK, font=font(34, bold=True))
        d.text((90, y + 76), sub, fill=SUBINK, font=font(26))
        tw = d.textlength(total, font=font(36, bold=True))
        d.text((s.w - 90 - tw, y + 48), total, fill=INK, font=font(36, bold=True))
        y += 160

    # Add service line ghost button
    rounded_rect(d, (60, y, s.w - 60, y + 100), 20, outline=ACCENT, width=3)
    d.text((90, y + 30), "+ Add service line", fill=ACCENT, font=font(30, bold=True))
    y += 140

    # Deposit + Pay via rows
    for label, value in [("Deposit", "30%"), ("Pay via", "Venmo @ratanjee-wash · Zelle 555-0142")]:
        rounded_rect(d, (60, y, s.w - 60, y + 100), 20, fill=CHIP)
        d.text((90, y + 32), label, fill=SUBINK, font=font(28))
        tw = d.textlength(value, font=font(30, bold=True))
        d.text((s.w - 90 - tw, y + 30), value, fill=INK, font=font(30, bold=True))
        y += 120

    # Before photos strip
    d.text((60, y), "Before photos", fill=SUBINK, font=font(24, bold=True))
    y += 40
    thumb_w = 180
    for i, tint in enumerate([(120, 160, 190), (140, 170, 150), (170, 150, 130)]):
        x = 60 + i * (thumb_w + 24)
        rounded_rect(d, (x, y, x + thumb_w, y + thumb_w), 16, fill=tint)
        d.rectangle((x, y + thumb_w - 40, x + thumb_w, y + thumb_w), fill=(80, 90, 100))
    # Add photo tile
    x = 60 + 3 * (thumb_w + 24)
    rounded_rect(d, (x, y, x + thumb_w, y + thumb_w), 16, outline=ACCENT, width=3)
    d.text((x + 40, y + 60), "+", fill=ACCENT, font=font(80, bold=True))
    y += thumb_w + 60

    # Live total pill above CTA
    total_row_y = s.h - s.home_indicator_h - s.tab_bar_h - 260
    rounded_rect(d, (60, total_row_y, s.w - 60, total_row_y + 100), 20, fill=CHIP)
    d.text((90, total_row_y + 32), "Total", fill=SUBINK, font=font(30))
    total_str = "$1,600.00"
    tw = d.textlength(total_str, font=font(46, bold=True))
    d.text((s.w - 90 - tw, total_row_y + 24), total_str, fill=INK, font=font(46, bold=True))

    # Primary CTA
    cta_y = total_row_y + 140
    rounded_rect(d, (60, cta_y, s.w - 60, cta_y + 110), 24, fill=ACCENT)
    save_font = font(38, bold=True)
    sw = d.textlength("Save quote", font=save_font)
    d.text(((s.w - sw) / 2, cta_y + 32), "Save quote", fill=(255, 255, 255), font=save_font)

    draw_home_indicator(img, s)
    return img


# ---------- Screen 3: Job detail / PDF preview ----------
def render_job_detail(s: Size) -> Image.Image:
    img = Image.new("RGB", (s.w, s.h), (245, 246, 248))
    d = ImageDraw.Draw(img)
    draw_status_bar(img, s)

    # Nav bar
    y = s.status_bar_h + 20
    d.polygon([(90, y + 40), (60, y + 70), (90, y + 100)], outline=ACCENT, width=6)
    d.text((120, y + 40), "Jobs", fill=ACCENT, font=font(32))
    title_font = font(52, bold=True)
    tw = d.textlength("Quote #1001", font=title_font)
    d.text(((s.w - tw) / 2, y + 34), "Quote #1001", fill=INK, font=title_font)
    y += 160

    # Status chip
    chip_label = "Sent · 2 days ago"
    chip_font = font(26, bold=True)
    cw = d.textlength(chip_label, font=chip_font) + 60
    ch = 60
    rounded_rect(d, (60, y, 60 + cw, y + ch), 30, fill=(220, 235, 246))
    d.text((90, y + 14), chip_label, fill=ACCENT_DARK, font=chip_font)
    y += ch + 40

    # PDF preview frame (paper look)
    pdf_x0, pdf_y0 = 80, y
    pdf_x1, pdf_y1 = s.w - 80, s.h - s.home_indicator_h - s.tab_bar_h - 240
    # shadow
    shadow = Image.new("RGBA", (pdf_x1 - pdf_x0 + 40, pdf_y1 - pdf_y0 + 40), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((20, 20, pdf_x1 - pdf_x0 + 20, pdf_y1 - pdf_y0 + 20),
                         radius=12, fill=(0, 0, 0, 60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    img.paste(shadow, (pdf_x0 - 20, pdf_y0 - 20), shadow)
    d.rounded_rectangle((pdf_x0, pdf_y0, pdf_x1, pdf_y1), radius=12, fill=(255, 255, 255))

    # PDF header: logo + business
    ly = pdf_y0 + 60
    # "logo" — accent square with initials
    rounded_rect(d, (pdf_x0 + 60, ly, pdf_x0 + 180, ly + 120), 20, fill=ACCENT)
    d.text((pdf_x0 + 92, ly + 28), "RW", fill=(255, 255, 255), font=font(56, bold=True))
    d.text((pdf_x0 + 220, ly + 8), "Ratanjee Wash & Detail",
           fill=INK, font=font(42, bold=True))
    d.text((pdf_x0 + 220, ly + 62),
           "4218 Harbor Rd · Tampa FL 33606",
           fill=SUBINK, font=font(24))
    d.text((pdf_x0 + 220, ly + 92),
           "(555) 555-0142 · quotes@ratanjeewash.com",
           fill=SUBINK, font=font(24))
    ly += 160
    d.line((pdf_x0 + 60, ly, pdf_x1 - 60, ly), fill=HAIR, width=2)
    ly += 30

    # Quote meta
    d.text((pdf_x0 + 60, ly), "Quote #1001", fill=INK, font=font(30, bold=True))
    d.text((pdf_x1 - 60 - d.textlength("Sep 16, 2026", font=font(26)), ly + 4),
           "Sep 16, 2026", fill=SUBINK, font=font(26))
    ly += 46
    d.text((pdf_x0 + 60, ly), "For: Maria Okafor · 212 Bayshore Dr",
           fill=SUBINK, font=font(26))
    ly += 60

    # Line items table
    d.line((pdf_x0 + 60, ly, pdf_x1 - 60, ly), fill=HAIR, width=2)
    ly += 12
    # Column x positions:
    #   Service label left-anchored at pdf_x0 + 60
    #   Rate meta right-anchored to (pdf_x1 - 260)  — leaves 200pt gap to Total
    #   Total right-anchored to (pdf_x1 - 60)
    rate_right = pdf_x1 - 260
    total_right = pdf_x1 - 60
    d.text((pdf_x0 + 60, ly), "Service", fill=SUBINK, font=font(22, bold=True))
    rate_hdr = "Qty × Rate"
    rw = d.textlength(rate_hdr, font=font(22, bold=True))
    d.text((rate_right - rw, ly), rate_hdr, fill=SUBINK, font=font(22, bold=True))
    d.text((total_right - d.textlength("Total", font=font(22, bold=True)), ly),
           "Total", fill=SUBINK, font=font(22, bold=True))
    ly += 40
    d.line((pdf_x0 + 60, ly, pdf_x1 - 60, ly), fill=HAIR, width=2)
    ly += 20
    for name, meta, total in [
        ("House soft wash", "2,400 sq ft × $0.30", "$720.00"),
        ("Roof",            "1,600 sq ft × $0.55", "$880.00"),
    ]:
        d.text((pdf_x0 + 60, ly), name, fill=INK, font=font(28, bold=True))
        mw = d.textlength(meta, font=font(26))
        d.text((rate_right - mw, ly + 2), meta, fill=INK, font=font(26))
        tw = d.textlength(total, font=font(28, bold=True))
        d.text((total_right - tw, ly), total, fill=INK, font=font(28, bold=True))
        ly += 60
    d.line((pdf_x0 + 60, ly, pdf_x1 - 60, ly), fill=HAIR, width=2)
    ly += 30

    for label, val in [
        ("Subtotal", "$1,600.00"),
        ("Deposit due (30%)", "$480.00"),
        ("Balance on completion", "$1,120.00"),
    ]:
        d.text((pdf_x0 + 60, ly), label, fill=INK, font=font(28, bold=(label != "Subtotal")))
        tw = d.textlength(val, font=font(30, bold=True))
        d.text((pdf_x1 - 60 - tw, ly), val, fill=INK, font=font(30, bold=True))
        ly += 50

    ly += 20
    d.text((pdf_x0 + 60, ly), "Pay via",
           fill=SUBINK, font=font(22, bold=True))
    ly += 32
    d.text((pdf_x0 + 60, ly), "Venmo @ratanjee-wash · Zelle 555-0142",
           fill=INK, font=font(26))
    ly += 60

    # Photo strip inside PDF
    photo_h = 180
    for i, tint in enumerate([(150, 180, 200), (130, 160, 140)]):
        px = pdf_x0 + 60 + i * (photo_h + 30)
        rounded_rect(d, (px, ly, px + photo_h, ly + photo_h), 12, fill=tint)
        d.rectangle((px, ly + photo_h - 40, px + photo_h, ly + photo_h), fill=(80, 90, 100))

    # Action row across the bottom
    action_y = pdf_y1 + 40
    actions = [
        ("Send PDF", ACCENT, (255, 255, 255), True),
        ("Convert to invoice", CHIP, INK, False),
        ("Add after photos", CHIP, INK, False),
        ("Deposit link", CHIP, INK, False),
    ]
    ax = 60
    aw = (s.w - 120 - 30) // 2  # two per row
    row_gap = 20
    for i, (label, bg, fg, primary) in enumerate(actions):
        col = i % 2
        row = i // 2
        bx = 60 + col * (aw + 30)
        by = action_y + row * (100 + row_gap)
        rounded_rect(d, (bx, by, bx + aw, by + 100), 20, fill=bg)
        af = font(30, bold=True)
        tw = d.textlength(label, font=af)
        d.text((bx + (aw - tw) / 2, by + 32), label, fill=fg, font=af)

    draw_home_indicator(img, s)
    return img


# ---------- Screen 4: Money ----------
def render_money(s: Size) -> Image.Image:
    img = Image.new("RGB", (s.w, s.h), BG)
    d = ImageDraw.Draw(img)
    draw_status_bar(img, s)

    y = draw_header(img, s, "Money", s.status_bar_h + 40)
    y += 30

    # Period toggle
    tabs = ["This week", "This month", "All time"]
    tab_x = 60
    tab_h = 80
    tab_w = (s.w - 120) // 3
    for i, t in enumerate(tabs):
        selected = (i == 1)
        rounded_rect(d,
                     (tab_x + i * tab_w, y, tab_x + (i + 1) * tab_w, y + tab_h),
                     22,
                     fill=ACCENT if selected else CHIP)
        tf = font(28, bold=True)
        tw = d.textlength(t, font=tf)
        d.text((tab_x + i * tab_w + (tab_w - tw) / 2, y + 22),
               t,
               fill=(255, 255, 255) if selected else INK,
               font=tf)
    y += tab_h + 80

    # 2x2 grid of totals
    totals = [
        ("Quoted",    "$4,547.00", ACCENT),
        ("Accepted",  "$1,455.00", ACCENT),
        ("Invoiced",  "$220.00",   ACCENT),
        ("Paid",      "$1,128.00", ACCENT),
    ]
    tile_w = (s.w - 60 - 60 - 40) // 2
    tile_h = 340
    for i, (label, val, _) in enumerate(totals):
        col = i % 2
        row = i // 2
        bx = 60 + col * (tile_w + 40)
        by = y + row * (tile_h + 40)
        rounded_rect(d, (bx, by, bx + tile_w, by + tile_h), 32, fill=CHIP)
        d.text((bx + 30, by + 30), label, fill=SUBINK, font=font(30, bold=True))
        vfont = font(84, bold=True)
        vw = d.textlength(val, font=vfont)
        d.text((bx + tile_w - 30 - vw, by + tile_h - 130), val, fill=INK, font=vfont)

    y += (tile_h + 40) * 2 + 40

    # Footnote: quiet caption
    d.text((60, y),
           "Tap a total to see the jobs behind it.",
           fill=SUBINK, font=font(26))

    draw_tab_bar(img, s, selected=3)
    draw_home_indicator(img, s)
    return img


# ---------- Screen 5: Services ----------
def render_services(s: Size) -> Image.Image:
    img = Image.new("RGB", (s.w, s.h), BG)
    d = ImageDraw.Draw(img)
    draw_status_bar(img, s)

    y = draw_header(img, s, "Services", s.status_bar_h + 40)
    y += 30

    services = [
        ("House soft wash", "$0.30 per sq ft"),
        ("Driveway",        "$0.20 per sq ft"),
        ("Roof",            "$0.55 per sq ft"),
        ("Deck",            "$0.35 per sq ft"),
        ("Fence",           "$4.00 per lin ft"),
        ("Commercial flatwork", "$0.15 per sq ft"),
    ]
    row_h = 160
    for i, (name, sub) in enumerate(services):
        rounded_rect(d, (60, y, s.w - 60, y + row_h - 20), 22, fill=BG, outline=HAIR, width=2)
        d.text((90, y + 30), name, fill=INK, font=font(36, bold=True))
        d.text((90, y + 84), sub, fill=SUBINK, font=font(28))
        # trailing "reorder" glyph
        for j in range(2):
            d.line((s.w - 160, y + 60 + j * 30, s.w - 100, y + 60 + j * 30),
                   fill=SUBINK, width=4)
        # trash
        d.rectangle((s.w - 260, y + 55, s.w - 220, y + 100), outline=SUBINK, width=3)
        d.line((s.w - 268, y + 55, s.w - 212, y + 55), fill=SUBINK, width=3)
        y += row_h

    # Add service CTA (bottom-anchored)
    cta_y = s.h - s.home_indicator_h - s.tab_bar_h - 180
    rounded_rect(d, (60, cta_y, s.w - 60, cta_y + 110), 24, fill=ACCENT)
    af = font(38, bold=True)
    text = "Add service"
    tw = d.textlength(text, font=af)
    d.text(((s.w - tw) / 2, cta_y + 32), text, fill=(255, 255, 255), font=af)

    draw_tab_bar(img, s, selected=2)
    draw_home_indicator(img, s)
    return img


def render_all(s: Size, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    for name, fn in [
        ("01-jobs", render_jobs),
        ("02-quote-builder", render_builder),
        ("03-job-detail", render_job_detail),
        ("04-money", render_money),
        ("05-services", render_services),
    ]:
        img = fn(s)
        p = out_dir / f"{name}.png"
        img.save(p, "PNG", optimize=True)
        print(f"wrote {p.relative_to(ROOT)} ({s.w}x{s.h})")


if __name__ == "__main__":
    render_all(IOS_SIZE, IOS_OUT)
    render_all(ANDROID_SIZE, ANDROID_OUT)
