"""The itch.io cover, 630x500: drawn at C64 resolution in the C64 palette, then scaled 3x.

Original artwork (the title lettering, aliens and ship are drawn here, not taken from the game).
Run: python make_cover.py -> cover_630x500.png
"""
import math, os, random
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SCALE = 3
W, H = 210, 167
OUT_W, OUT_H = 630, 500
VERSION = 'V1.07'

PAL = [(0, 0, 0), (255, 255, 255), (136, 57, 50), (103, 182, 189), (139, 63, 150), (85, 160, 73), (64, 49, 141),
       (191, 206, 114), (139, 84, 41), (87, 66, 0), (184, 105, 98), (80, 80, 80), (120, 120, 120), (148, 224, 137),
       (120, 105, 196), (159, 159, 159)]
BLACK, WHITE, RED, CYAN, PURPLE, GREEN, BLUE, YELLOW, ORANGE, BROWN, LIGHT_RED, DARK_GREY, GREY, LIGHT_GREEN, LIGHT_BLUE, LIGHT_GREY = range(16)

img = Image.new('RGB', (W, H), PAL[BLACK])
px = img.load()


def plot(x, y, c):
    if 0 <= x < W and 0 <= y < H:
        px[x, y] = PAL[c]


def shape(rows, x, y, colours, mirror=False):
    """rows of characters; each character's colour comes from the colours dict ('.' = clear)"""
    for j, row in enumerate(rows):
        if mirror:
            row = row[::-1]
        for i, ch in enumerate(row):
            if ch in colours:
                plot(x + i, y + j, colours[ch])


# --- the starfield: three depths, some stars twinkling in colour --------------------------------

random.seed(1907)
for _ in range(170):
    x, y = random.randrange(W), random.randrange(H)
    c = random.choice([DARK_GREY, DARK_GREY, GREY, GREY, LIGHT_GREY, WHITE, LIGHT_BLUE, CYAN, YELLOW])
    plot(x, y, c)
    if c == WHITE and random.random() < 0.3:          # a few bright ones with a cross
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            plot(x + dx, y + dy, LIGHT_BLUE)

# a band of distant nebula behind the formation, dithered
for y in range(54, 96):
    for x in range(W):
        d = abs(y - 75) / 21 + abs(x - 105) / 140
        if d < 1 and (x + y) % 2 == 0 and random.random() > d + 0.35:
            plot(x, y, BLUE if random.random() > 0.35 else PURPLE)

# --- the title: chunky letters with C64 raster bars, an outline and a drop shadow ----------------

FONT = {
    'G': ['.######.', '##....##', '##......', '##......', '##..####', '##....##', '##....##', '.######.'],
    'A': ['..####..', '.##..##.', '##....##', '##....##', '########', '##....##', '##....##', '##....##'],
    'L': ['##......', '##......', '##......', '##......', '##......', '##......', '##......', '########'],
}
TITLE = 'GALAGA'
T_SCALE = 3
T_GAP = 2
title_w = (len(TITLE) * 8 + (len(TITLE) - 1) * T_GAP) * T_SCALE
tx, ty = (W - title_w) // 2, 10
BARS = [WHITE, YELLOW, YELLOW, YELLOW, LIGHT_RED, LIGHT_RED, RED, LIGHT_RED, RED, RED, PURPLE, PURPLE]

mask = set()
for n, letter in enumerate(TITLE):
    lx = tx + n * (8 + T_GAP) * T_SCALE
    for j, row in enumerate(FONT[letter]):
        for i, ch in enumerate(row):
            if ch == '#':
                for sy in range(T_SCALE):
                    for sx in range(T_SCALE):
                        mask.add((lx + i * T_SCALE + sx, ty + j * T_SCALE + sy))

for (x, y) in mask:                                   # drop shadow
    if (x + 2, y + 2) not in mask:
        plot(x + 2, y + 2, BLUE)
for (x, y) in mask:                                   # outline
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        if (x + dx, y + dy) not in mask:
            plot(x + dx, y + dy, DARK_GREY if dy >= 0 else LIGHT_BLUE)
for (x, y) in mask:                                   # raster bars, two pixel rows each
    plot(x, y, BARS[min((y - ty) // 2, len(BARS) - 1)])
for (x, y) in mask:                                   # a glint along the top edges
    if (x, y - 1) not in mask and (x - y) % 7 < 3:
        plot(x, y, WHITE)

# --- small type ----------------------------------------------------------------------------------

SMALL = {
    'C': ['.###', '#...', '#...', '#...', '.###'], 'O': ['.##.', '#..#', '#..#', '#..#', '.##.'],
    'M': ['#...#', '##.##', '#.#.#', '#...#', '#...#'], 'D': ['###.', '#..#', '#..#', '#..#', '###.'],
    'R': ['###.', '#..#', '###.', '#.#.', '#..#'], 'E': ['####', '#...', '###.', '#...', '####'],
    '6': ['.##.', '#...', '###.', '#..#', '.##.'], '4': ['#..#', '#..#', '####', '...#', '...#'],
    'V': ['#...#', '#...#', '#...#', '.#.#.', '..#..'], '1': ['.#', '##', '.#', '.#', '.#'],
    '.': ['.', '.', '.', '.', '#'], '0': ['.##.', '#..#', '#..#', '#..#', '.##.'],
    '7': ['####', '...#', '..#.', '.#..', '.#..'], 'A': ['.##.', '#..#', '####', '#..#', '#..#'],
    'L': ['#...', '#...', '#...', '#...', '####'], 'S': ['.###', '#...', '.##.', '...#', '###.'],
    'F': ['####', '#...', '###.', '#...', '#...'], 'T': ['###', '.#.', '.#.', '.#.', '.#.'],
    'K': ['#..#', '#.#.', '##..', '#.#.', '#..#'], 'P': ['###.', '#..#', '###.', '#...', '#...'],
    'I': ['#', '#', '#', '#', '#'], ' ': ['..', '..', '..', '..', '..'], '-': ['...', '...', '###', '...', '...'],
    '&': ['.#..', '#.#.', '.#.#', '#.#.', '.#.#'],
}


def text_width(s):
    return sum(len(SMALL[ch][0]) + 1 for ch in s) - 1


def text(s, x, y, colour, shadow=None):
    for ch in s:
        g = SMALL[ch]
        if shadow is not None:
            shape(g, x + 1, y + 1, {'#': shadow})
        shape(g, x, y, {'#': colour})
        x += len(g[0]) + 1


sub = 'COMMODORE 64'
text(sub, (W - text_width(sub)) // 2, ty + 8 * T_SCALE + 7, LIGHT_BLUE, BLUE)

# --- the aliens: three original designs in a formation ------------------------------------------

SAUCER = ['...###...', '..#***#..', '.#######.', '#.#.#.#.#', '.#######.', '...#.#...']
MANTA = ['#...#...#', '##.###.##', '#########', '.##.#.##.', '..#####..', '...#.#...']
STINGER = ['....#....', '...###...', '..#*#*#..', '.#######.', '..#####..', '...#.#...', '....#....']

ROWS = [
    (MANTA, {'#': LIGHT_GREEN}, 4, 62),
    (STINGER, {'#': LIGHT_RED, '*': WHITE}, 6, 72),
    (STINGER, {'#': LIGHT_RED, '*': WHITE}, 6, 81),
    (SAUCER, {'#': LIGHT_BLUE, '*': CYAN}, 8, 91),
    (SAUCER, {'#': LIGHT_BLUE, '*': CYAN}, 8, 99),
]
diver = None
for n, (rows, colours, count, y) in enumerate(ROWS):
    spacing = 13
    x0 = (W - (count * spacing - (spacing - 9))) // 2
    for i in range(count):
        if n == 1 and i == count - 1:                  # this one has peeled off to dive
            diver = (x0 + i * spacing, y)
            continue
        shape(rows, x0 + i * spacing, y + (i % 2 if n >= 3 else 0), colours)

# the diver's looping path, as a trail of fading dots, ending at the diving alien
cx, cy = diver[0] + 4, diver[1] + 3
path = []
for k in range(70):
    t = k / 69
    a = math.pi * 1.6 * t
    x = cx + 22 * math.sin(a) + 18 * t
    y = cy + 10 + 45 * t - 12 * math.cos(a) + 12
    path.append((int(x), int(y)))
for k, (x, y) in enumerate(path[:-6]):
    if k % 3 == 0:
        plot(x, y, [RED, LIGHT_RED, YELLOW][min(2, k * 3 // len(path))])
dx, dy = path[-1]
shape(STINGER, dx - 4, dy - 3, {'#': LIGHT_RED, '*': WHITE})

# --- the player's ship, firing ------------------------------------------------------------------

SHIP = ['....##....',
        '...#WW#...',
        '...#WW#...',
        '..######..',
        '.##.##.##.',
        '##########',
        '#.##..##.#',
        '.O......O.',
        '.Y......Y.']
sx, sy = 98, 146
shape(SHIP, sx, sy, {'#': CYAN, 'W': WHITE, 'O': ORANGE, 'Y': YELLOW})
for y in range(sy - 30, sy - 4, 1):                    # the shot, with a gap: two bolts
    if (y - (sy - 30)) % 13 < 5:
        plot(sx + 4, y, WHITE)
        plot(sx + 5, y, YELLOW)

# an alien caught by a shot: a starburst
bx, by = 70, 122
BURST = ['#...#...#', '.#..#..#.', '..#.*.#..', '...***...', '###*O*###', '...***...', '..#.*.#..', '.#..#..#.', '#...#...#']
shape(BURST, bx, by, {'#': ORANGE, '*': YELLOW, 'O': WHITE})

# --- the footer ---------------------------------------------------------------------------------

text('ARLASOFT', 4, H - 9, LIGHT_GREY, DARK_GREY)
ver_w = text_width(VERSION) + 4
vx, vy = W - ver_w - 3, H - 11
for y in range(vy, vy + 9):                            # a little badge for the version
    for x in range(vx, vx + ver_w):
        edge = y in (vy, vy + 8) or x in (vx, vx + ver_w - 1)
        plot(x, y, LIGHT_BLUE if edge else BLUE)
text(VERSION, vx + 2, vy + 2, WHITE)
text('DISK & TAPE', 4, H - 17, GREY)

out = img.resize((W * SCALE, H * SCALE), Image.NEAREST).crop((0, 0, OUT_W, OUT_H))
out.save(os.path.join(HERE, 'cover_630x500.png'))
print('wrote', os.path.join(HERE, 'cover_630x500.png'))
