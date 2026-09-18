"""Genere les icones launcher Zefir (PNG RGBA) sans dependance externe.

Dessin : carre bleu M3 (#0B57D0) a coins arrondis, disque blanc,
triangle de lecture bleu. Antialiasing par supersampling 4x4.

Usage : python tools/gen_icons.py
"""
import os
import struct
import zlib

BLUE = (11, 87, 208, 255)        # #0B57D0 primary
WHITE = (255, 255, 255, 255)     # onPrimary
RES = os.path.join("android", "app", "src", "main", "res")

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def in_rounded_rect(x, y, s, radius_frac=0.18):
    r = s * radius_frac
    if x < 0 or x > s or y < 0 or y > s:
        return False
    in_corner_zone = (x < r or x > s - r) and (y < r or y > s - r)
    if not in_corner_zone:
        return True
    cx = r if x < r else s - r
    cy = r if y < r else s - r
    return (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def in_circle(x, y, cx, cy, r):
    return (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def in_triangle(px, py, a, b, c):
    def sign(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])

    d1 = sign((px, py), a, b)
    d2 = sign((px, py), b, c)
    d3 = sign((px, py), c, a)
    has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (has_neg and has_pos)


def sample(u, v, s):
    """Couleur (RGBA) pour le point normalise (u, v) dans [0, 1]."""
    x, y = u * s, v * s
    if not in_rounded_rect(x, y, s):
        return (0, 0, 0, 0)
    if in_circle(x, y, s * 0.50, s * 0.50, s * 0.26):
        if in_triangle(x, y, (s * 0.44, s * 0.38), (s * 0.66, s * 0.50), (s * 0.44, s * 0.62)):
            return BLUE
        return WHITE
    return BLUE


def render(size):
    ss = 4
    rows = []
    acc = [0.0, 0.0, 0.0, 0.0]
    for py in range(size):
        row = bytearray()
        for px in range(size):
            r = g = b = a = 0.0
            for sy in range(ss):
                for sx in range(ss):
                    u = (px + (sx + 0.5) / ss) / size
                    v = (py + (sy + 0.5) / ss) / size
                    pr, pg, pb, pa = sample(u, v, 100.0)
                    r += pr
                    g += pg
                    b += pb
                    a += pa
            n = ss * ss
            row += bytes((
                int(r / n + 0.5),
                int(g / n + 0.5),
                int(b / n + 0.5),
                int(a / n + 0.5),
            ))
        rows.append(bytes(row))
    return rows


def write_png(path, size, rows):
    raw = b"".join(b"\x00" + row for row in rows)

    def chunk(tag, data):
        payload = tag + data
        return (
            struct.pack(">I", len(data))
            + payload
            + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
        )

    header = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as fh:
        fh.write(png)


def main():
    for folder, size in SIZES.items():
        target = os.path.join(RES, folder)
        os.makedirs(target, exist_ok=True)
        out = os.path.join(target, "ic_launcher.png")
        write_png(out, size, render(size))
        print(f"OK {out} ({size}x{size})")


if __name__ == "__main__":
    main()
