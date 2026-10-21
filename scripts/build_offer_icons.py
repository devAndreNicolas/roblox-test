"""Draw original, compact Bingo Noir marketplace icons (512 px PNG)."""

from pathlib import Path
from PIL import Image, ImageDraw


SIZE = 512
SCALE = 2
OUT = Path(__file__).resolve().parents[1] / "assets" / "bingo" / "offer-icons"
OUT.mkdir(parents=True, exist_ok=True)

GOLD = "#f7c75f"
IVORY = "#fff5d9"
INK = "#13203a"


def icon(name, bg, accent, draw_motif):
    im = Image.new("RGBA", (SIZE * SCALE, SIZE * SCALE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    def box(x0, y0, x1, y1):
        return tuple(round(v * SCALE) for v in (x0, y0, x1, y1))
    d.ellipse(box(16, 16, 496, 496), fill=INK)
    d.ellipse(box(28, 28, 484, 484), fill=bg, outline=GOLD, width=10 * SCALE)
    d.ellipse(box(46, 46, 466, 466), outline=accent, width=3 * SCALE)
    draw_motif(d, box, accent)
    im.resize((SIZE, SIZE), Image.Resampling.LANCZOS).save(OUT / f"{name}.png", optimize=True)


def coin(d, b, x, y, r=52, fill=GOLD):
    d.ellipse(b(x-r, y-r, x+r, y+r), fill=fill, outline=IVORY, width=5*SCALE)
    d.ellipse(b(x-r+14, y-r+14, x+r-14, y+r-14), outline=INK, width=5*SCALE)
    d.line([tuple(v*SCALE for v in p) for p in [(x-16,y),(x,y-17),(x+16,y),(x,y+17),(x-16,y)]], fill=INK, width=6*SCALE, joint="curve")


def ficha_120(d, b, accent):
    coin(d,b,256,256,120)


def ficha_350(d, b, accent):
    coin(d,b,214,282,84)
    coin(d,b,298,232,84)


def ficha_800(d, b, accent):
    d.rounded_rectangle(b(104,220,408,376), radius=30*SCALE, fill=INK, outline=GOLD, width=12*SCALE)
    d.rounded_rectangle(b(196,158,316,234), radius=18*SCALE, outline=IVORY, width=11*SCALE)
    d.line([tuple(v*SCALE for v in p) for p in [(114,286),(398,286)]], fill=GOLD, width=8*SCALE)
    coin(d,b,256,286,57)


def suborn(d, b, accent):
    d.rounded_rectangle(b(213,123,299,292), radius=40*SCALE, fill=accent, outline=IVORY, width=8*SCALE)
    d.arc(b(171,184,341,345), 0, 180, fill=GOLD, width=14*SCALE)
    d.line([tuple(v*SCALE for v in p) for p in [(256,345),(256,389),(194,389),(318,389)]], fill=GOLD, width=13*SCALE, joint="curve")
    d.polygon([(337*SCALE,138*SCALE),(351*SCALE,172*SCALE),(385*SCALE,186*SCALE),(351*SCALE,201*SCALE),(337*SCALE,235*SCALE),(323*SCALE,201*SCALE),(289*SCALE,186*SCALE),(323*SCALE,172*SCALE)], fill=GOLD)


def dossier(d, b, accent):
    d.rounded_rectangle(b(114,146,398,376), radius=16*SCALE, fill=accent, outline=IVORY, width=8*SCALE)
    d.polygon([(114*SCALE,178*SCALE),(178*SCALE,178*SCALE),(201*SCALE,144*SCALE),(300*SCALE,144*SCALE),(322*SCALE,178*SCALE),(398*SCALE,178*SCALE)], fill=GOLD)
    for y, end in [(242, 350), (292, 318)]:
        d.line([tuple(v*SCALE for v in p) for p in [(157,y),(end,y)]], fill=IVORY, width=11*SCALE)


def star(d, b, accent):
    import math
    points=[]
    for i in range(10):
        angle=-math.pi/2+i*math.pi/5
        radius=143 if i%2==0 else 63
        points.append((round((256+math.cos(angle)*radius)*SCALE),round((256+math.sin(angle)*radius)*SCALE)))
    d.polygon(points, fill=GOLD)
    d.line(points+[points[0]], fill=IVORY, width=6*SCALE, joint="curve")


def seal(d, b, accent):
    d.ellipse(b(120,120,392,392), fill=GOLD, outline=IVORY, width=8*SCALE)
    d.ellipse(b(151,151,361,361), fill=accent, outline=INK, width=9*SCALE)
    d.ellipse(b(189,189,323,323), outline=IVORY, width=12*SCALE)
    d.polygon([(256*SCALE,177*SCALE),(276*SCALE,235*SCALE),(335*SCALE,256*SCALE),(276*SCALE,277*SCALE),(256*SCALE,335*SCALE),(236*SCALE,277*SCALE),(177*SCALE,256*SCALE),(236*SCALE,235*SCALE)],fill=GOLD)


def on_air(d, b, accent):
    d.rounded_rectangle(b(160,181,352,335), radius=24*SCALE, fill=INK, outline=accent, width=13*SCALE)
    d.ellipse(b(215,215,297,297), fill=accent, outline=IVORY, width=8*SCALE)
    d.arc(b(112,132,400,380), 205, 335, fill=IVORY, width=11*SCALE)
    d.arc(b(81,94,431,418), 205, 335, fill=GOLD, width=11*SCALE)


def velvet(d, b, accent):
    d.polygon([(118*SCALE,116*SCALE),(394*SCALE,116*SCALE),(358*SCALE,374*SCALE),(154*SCALE,374*SCALE)], fill=accent, outline=GOLD)
    d.line([tuple(v*SCALE for v in p) for p in [(118,116),(197,220),(256,116),(315,220),(394,116)]], fill=GOLD, width=9*SCALE)
    d.line([tuple(v*SCALE for v in p) for p in [(154,374),(256,255),(358,374)]], fill=IVORY, width=9*SCALE)
    d.ellipse(b(223,222,289,288), fill=GOLD)


for name, bg, accent, motif in [
    ("fichas_120", "#314c82", GOLD, ficha_120),
    ("fichas_350", "#314c82", GOLD, ficha_350),
    ("fichas_800", "#314c82", GOLD, ficha_800),
    ("suborn", "#74304e", "#dd7491", suborn),
    ("dossier_blue", "#1c416e", "#406fa9", dossier),
    ("stage_star", "#742d4b", "#a84969", star),
    ("club_seal", "#244373", "#244373", seal),
    ("on_air", "#12384f", "#1cd5e4", on_air),
    ("velvet_gala", "#64253d", "#a34266", velvet),
]:
    icon(name, bg, accent, motif)

print(f"Wrote 9 offer icons to {OUT}")
