"""Rebuilds galaga.sng from transcriptions of the arcade Galaga tunes and packs galaga.sid.

Run:  python arcade_music.py [path to gt2reloc.exe]
      (default C:/Users/nicks/Dropbox/C64/Tools/goattrk2/win32/gt2reloc.exe)

This regenerates every subtune, instrument and table in galaga.sng (only the song name and
author are kept), so hand edits made in GoatTracker are lost if it is run again. The packer
options match the original release: player at $6000, zeropage $fc, sound effects and volume
support on, pulse optimisation off.

Arcade reference: the sound CPU (gg1-7) plays each voice as a list of (note, length) pairs at
121 Hz (8.25 ms ticks) on the 3-voice Namco WSG. Lengths below are in those ticks. Each tune is
laid on a row grid whose row matches a whole number of ticks (12 ticks = 5 frames, 10 = 4,
5 = 2, 16 = 7/6 alternating). Envelopes are matched per voice: flat (legato, no retrigger),
"accent" (14 dropping to 10), or plucked (14 decaying towards 0). Waveforms by spectrum:
WSG wave 7 ~ 37.5% pulse, 6 ~ 25%, 4 ~ 12.5%, 5 ~ sawtooth, 3 and 2 ~ square, 0 ~ triangle.
"""
import math
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SNG = os.path.join(HERE, 'galaga.sng')
SID = os.path.join(HERE, 'galaga.sid')
GT2RELOC = r'C:/Users/nicks/Dropbox/C64/Tools/goattrk2/win32/gt2reloc.exe'

NAMES = ['C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-']
EMPTY, KEYOFF, ENDMARK = 0xBD, 0xBE, 0xFF
TICK_HZ = 18432000 / 3 / 384 / 264 * 2


def note(name):
    return NAMES.index(name[:2]) + 12 * int(name[2:])


# --- arcade transcriptions (note:ticks, r = rest) ----------------------------------------

START_V0 = ('G-3:36 C-4:12 D-4:36 F-4:12 E-4:36 C-4:12 D-4:36 A-4:12 G-4:36 C-4:12 D-4:36 F-4:12 '
            'E-4:36 C-4:12 G-4:36 B-4:12 C-5:36 A#4:12 G#4:36 G-4:12 F-4:36 D#4:12 D-4:36 A#3:12 '
            'A#4:36 C-5:12 A#4:36 G-4:12 A-4:16 F-4:16 D-4:16 G-4:16 E-4:16 D-4:16 r:64')
START_V1 = ('E-4:36 G-3:12 D-4:36 A-3:12 C-4:36 G-3:12 A-3:36 B-3:12 E-4:36 G-3:12 D-4:36 A-3:12 '
            'C-4:36 G-3:12 D-4:36 G-4:12 G#4:36 G-4:12 F-4:36 D#4:12 D-4:36 C-4:12 A#3:36 D-4:12 '
            'D#4:36 F-4:12 D#4:36 C-4:12 F-4:16 D-4:16 A-3:16 D-4:16 B-3:16 A-3:16 r:64')
START_V2 = ('G-3:48 A-3:36 C-4:12 B-3:48 G-3:48 C-4:48 D-4:36 F-4:12 E-4:48 D-4:48 D#4:48 D-4:36 '
            'C-4:12 A#3:48 D#4:48 A#4:48 G-4:36 D#4:12 D-4:48 G-4:36 E-4:12 r:64')

CAPTURED_V0 = ('E-5:12 C-5:12 D-5:12 B-4:12 C-5:12 A-4:12 B-4:12 G#4:12 A-4:12 E-4:12 F-4:12 D-4:12 '
               'C-4:12 B-3:12 A-3:12 G#3:12 A-3:12 C-4:12 B-3:12 D-4:12 C-4:12 E-4:12 D-4:12 F-4:12 '
               'E-4:12 A-4:12 G#4:12 A-4:12 B-4:12 E-4:12 F#4:12 G#4:12')
CAPTURED_V1 = ('C-5:12 A-4:12 B-4:12 G#4:12 A-4:12 F#4:12 G#4:12 E-4:12 F-4:12 C-4:12 D-4:12 B-3:12 '
               'A-3:12 G#3:12 F#3:12 E-3:12 E-3:12 A-3:12 G#3:12 B-3:12 A-3:12 C-4:12 B-3:12 D-4:12 '
               'C-4:12 E-4:12 D-4:12 F-4:12 E-4:12 D-4:12 C-4:12 B-3:12')
CAPTURED_V2 = ('A-2:24 E-3:24 A-3:36 E-3:12 D-3:12 C-3:12 B-2:12 A-2:24 B-2:36 C-3:24 D-3:24 E-3:24 '
               'F-3:24 E-3:24 D-3:12 C-3:12 B-2:12 G#2:12 A-2:12 B-2:12')

# The rescued-ship tune is the captured tune in A major. The arcade data has F#3 (an octave
# low) where the captured tune has F-4; kept as the arcade plays it.
RESCUED_V0 = ('E-5:12 C#5:12 D-5:12 B-4:12 C#5:12 A-4:12 B-4:12 G#4:12 A-4:12 E-4:12 F#3:12 D-4:12 '
              'C#4:12 B-3:12 A-3:12 G#3:12 A-3:12 C#4:12 B-3:12 D-4:12 C#4:12 E-4:12 D-4:12 F#3:12 '
              'E-4:12 A-4:12 G#4:12 A-4:12 B-4:12 E-4:12 F#4:12 G#4:12')
RESCUED_V1 = ('C#5:12 A-4:12 B-4:12 G#4:12 A-4:12 F#4:12 G#4:12 E-4:12 F#3:12 C#4:12 D-4:12 B-3:12 '
              'A-3:12 G#3:12 F#3:12 E-3:12 E-3:12 A-3:12 G#3:12 B-3:12 A-3:12 C#4:12 B-3:12 D-4:12 '
              'C#4:12 E-4:12 D-4:12 F#3:12 E-4:12 D-4:12 C#4:12 B-3:12')
RESCUED_V2 = ('A-2:24 E-3:24 A-3:36 E-3:12 D-3:12 C#3:12 B-2:12 A-2:24 B-2:36 C#3:24 D-3:24 E-3:24 '
              'F#2:24 E-3:24 D-3:12 C#3:12 B-2:12 G#2:12 A-2:12 B-2:12')

PERFECT_V0 = ('E-5:25 r:5 E-5:5 r:5 E-5:15 r:5 D-5:35 r:5 D-5:35 r:5 D-5:15 r:5 F-5:25 r:5 F-5:5 r:5 '
              'F-5:15 r:5 E-5:35 r:5 E-5:35 r:5 E-5:15 r:5 F-5:5 r:5 F-5:5 r:15 F-5:5 r:5 F-5:15 r:5 '
              'G-5:5 r:5 G-5:5 r:15 G-5:5 r:5 G-5:15 r:5 G-5:15 r:5 G-5:15 r:5 A-5:5 r:5 A-5:5 r:15 '
              'A-5:5 r:5 A-5:15 r:5 A-5:15 r:5 A-5:15 r:5')
PERFECT_V1 = ('C-4:10 E-4:10 G-4:10 C-5:10 ' * 8 +
              'C#5:5 r:5 C#5:5 r:15 C#5:5 r:5 C#5:15 r:5 D#6:5 r:5 D#6:5 r:15 D#6:5 r:5 D#6:15 r:5 '
              'D#6:15 r:5 D#6:15 r:5 F-4:10 A-4:10 C-5:10 F-5:10 F-5:10 C-5:10 A-4:10 F-4:10')
PERFECT_V2 = ('C-4:40 G-3:40 ' * 4 +
              'G#3:5 r:5 G#3:5 r:15 G#3:5 r:5 G#3:15 r:5 A#3:5 r:5 A#3:5 r:15 A#3:5 r:5 A#3:15 r:5 '
              'A#3:15 r:5 A#3:15 r:5 F-5:40 C-5:20 F-4:20')

HISCORE1_V0 = ('F#5:10 D-5:10 B-4:10 G-4:10 ' * 6 +
               'F#5:10 r:10 D-5:10 E-5:10 B-4:10 D-5:10 A-4:10 B-4:10 ' +
               'G-5:10 E-5:10 C-5:10 A-4:10 ' * 4 +
               'G-5:10 D#5:10 C-5:10 A-4:10 ' * 2 +
               'G-5:10 r:10 D#5:10 G-5:10 D-5:10 D#5:10 B-4:10 D-5:10')
HISCORE1_V1 = ('G-5:20 D-5:20 D-5:20 ' * 4 + 'G-5:20 D-5:20 E-5:20 B-4:20 ' +
               'A-5:20 E-5:20 E-5:20 ' * 2 + 'A-5:20 E-5:20 D#5:20 ' +
               'A-5:20 D#5:20 D#5:20 A-5:20 D#5:20 C-5:20 A-4:20')
HISCORE1_V2 = 'B-3:60 B-3:60 B-3:60 B-3:60 B-3:40 B-3:40 C-4:60 C-4:60 C-4:60 C-4:60 C-4:40 C-4:40'
HISCORE1_TAIL = ['F#5:10 F#5:10 F#5:10', 'D-5:10 D-5:10 D-5:10', 'G-3:10 G-3:10 G-3:10']

HISCORE2_V0 = ('B-4:48 G-4:48 E-4:48 C-4:48 r:36 B-4:12 G-4:36 E-4:12 C-4:16 E-4:16 G-4:16 D#4:16 '
               'F#4:16 A-4:16 F-4:48 A-4:48 C-5:48 D-5:48 r:36 D#5:12 C-5:36 G#4:12 F-4:16 D#4:16 '
               'C-4:16 G#4:16 D#4:16 C-5:16')
HISCORE2_V1 = ('G-4:48 E-4:48 C-4:48 B-3:48 r:36 G-3:12 E-4:36 C-4:12 B-3:16 C-4:16 E-4:16 C-4:16 '
               'D#4:16 F-4:16 D-4:48 F-4:48 A-4:48 C-5:48 r:36 C-5:12 G#4:36 F-4:12 E-4:16 C-4:16 '
               'G#3:16 F-4:16 D#4:16 G#3:16')
HISCORE2_V2 = 'B-4:288 G-4:48 B-4:48 A-4:192 G#4:96 C-5:48 D-5:48'

# Tractor beam loops, 4 ticks (33 ms) a note. The wavetable plays them at 2,2,1,2,2,1,1,1 frames
# and the frame where the pattern re-strikes the note holds the last one, 13 frames a figure.
BEAM = 'G-5 E-5 F#5 D-5 E-5 C-5 D-5 B-4'
BEAM_CATCH = 'C-5 D#5 F#5 A-5 C-6 A-5 F#5 D#5'
BEAM_FRAMES = [2, 2, 1, 2, 2, 1, 1, 1]

# Formation "pulse" drone (arcade effect $00, generated in code): each 34-tick segment starts at
# a 16-bit value and adds an increment every tick; pitch = high byte * 1.465 Hz. The formation
# turns every 256 ticks, so 7 1/2 rising segments are followed by 7 1/2 falling ones.
DRONE_UP = [(0x5B00, 0x130), (0x6C00, 0x168), (0x5B00, 0x136), (0x7E00, 0x1A8),
            (0x6C00, 0x168), (0x9700, 0x200), (0x8100, 0x1AC), (0x9900, 0x208)]
DRONE_DOWN = [(0xD900, -0x200), (0xB600, -0x1A8), (0xD900, -0x1F8), (0x9700, -0x168),
              (0xB600, -0x1A8), (0x7E00, -0x130), (0x9900, -0x168), (0x8100, -0x12A)]


# --- song building -----------------------------------------------------------------------

class Song:
    def __init__(self, header):
        self.header = header            # name, author, copyright (96 bytes)
        self.instr = []                 # (9 params, 16-byte name)
        self.tables = [([], []), ([], []), ([], []), ([], [])]   # wave, pulse, filter, speed
        self.patterns = []
        self.orders = []

    def table(self, t, rows):
        """Appends rows (left, right) to table t, returns the 1-based start position. An
        identical program already in the table is shared instead."""
        left, right = self.tables[t]
        for s in range(len(left) - len(rows) + 1):
            if list(zip(left[s:s + len(rows)], right[s:s + len(rows)])) == rows and rows[-1][0] == 0xFF:
                return s + 1
        start = len(left) + 1
        for l, r in rows:
            left.append(l)
            right.append(r)
        return start

    def speed(self, left, right):
        left_t, right_t = self.tables[3]
        for i in range(len(left_t)):
            if left_t[i] == left and right_t[i] == right:
                return i + 1
        return self.table(3, [(left, right)])

    def instrument(self, name, ad, sr, wave_rows, pulse=None, gate=0x01, first=0x09, loop=False):
        if loop:            # the closing jump goes back to the program's first row
            left, right = self.tables[0]
            wave = len(left) + 1
            for l, r in wave_rows + [(0xFF, wave)]:
                left.append(l)
                right.append(r)
        else:
            wave = self.table(0, wave_rows + [(0xFF, 0x00)])
        pls = self.table(1, [(0x80 | pulse >> 8, pulse & 0xFF), (0xFF, 0x00)]) if pulse is not None else 0
        self.instr.append(([ad, sr, wave, pls, 0, 0, 0, gate, first], name.encode().ljust(16, b'\0')[:16]))
        if gate & 0x40:
            LEGATO.add(len(self.instr))
        return len(self.instr)

    def pattern(self, rows):
        self.patterns.append(rows + [(ENDMARK, 0, 0, 0)])
        return len(self.patterns) - 1

    def save(self, path):
        out = bytearray(b'GTS5' + self.header)
        out.append(len(self.orders))
        for chans in self.orders:
            for o in chans:
                out.append(len(o) - 1)
                out += bytes(o)
        out.append(len(self.instr))
        for params, name in self.instr:
            out += bytes(params) + name
        for left, right in self.tables:
            out.append(len(left))
            out += bytes(left) + bytes(right)
        out.append(len(self.patterns))
        for pat in self.patterns:
            out.append(len(pat))
            for r in pat:
                out += bytes(r)
        open(path, 'wb').write(bytes(out))


def events(text):
    t = 0
    out = []
    for item in text.split():
        name, ticks = item.split(':')
        out.append((t, None if name == 'r' else note(name), int(ticks)))
        t += int(ticks)
    return out


class Grid:
    """Piecewise row grid: [(start tick, ticks per row, tempo)], tempo an int or a (a, b) pair."""
    def __init__(self, sections):
        self.sections = sections

    def row(self, t):
        r = 0.0
        for i, (start, per, _) in enumerate(self.sections):
            end = self.sections[i + 1][0] if i + 1 < len(self.sections) else 1 << 30
            if t <= start:
                break
            r += (min(t, end) - start) / per
        # The start theme's last bar has 12-tick notes against 16-tick ones; one note lands
        # 4 ticks (33 ms) off the 16-tick rows and is moved to the nearest row.
        assert abs(r - round(r)) <= 0.25, 'tick %d is not on the row grid' % t
        return int(round(r))


REST = None      # set by build(): see the ARC REST instrument
LEGATO = set()   # instruments without gateoff/hard restart


def voice_rows(text, instr, grid, total_rows):
    """On a legato voice, a rest followed by a note plays the REST instrument on the previous
    pitch rather than a keyoff. A legato note's gate-on comes a frame early (with the note
    fetch), which after a plain keyoff would sound that frame at the old pitch; REST leaves the
    waveform register's gate bit clear, so the gate only opens when the new note's wavetable
    runs. Hard-restart instruments open the gate on the note's first frame anyway."""
    rows = [[EMPTY, 0, 0, 0] for _ in range(total_rows)]
    evs = events(text)
    prev = None
    current = None
    for i, (t, n, ticks) in enumerate(evs):
        r = grid.row(t)
        if n is None:
            followed = any(e[1] is not None for e in evs[i + 1:])
            if rows[r][0] == EMPTY:
                if followed and instr in LEGATO and prev is not None:
                    rows[r][0], rows[r][1] = 0x60 + prev, REST
                    current = REST
                else:
                    rows[r][0] = KEYOFF
            continue
        rows[r][0] = 0x60 + n
        if current != instr:
            rows[r][1] = instr
            current = instr
        prev = n
    return rows


def tempo_commands(song, grid, rows0):
    """Global tempo commands on voice 0 at each grid section start."""
    for start, per, tempo in grid.sections:
        r = grid.row(start)
        if isinstance(tempo, tuple):
            rows0[r][2], rows0[r][3] = 0xE, song.speed(*tempo)
        else:
            rows0[r][2], rows0[r][3] = 0xF, tempo


def split(song, rows, size=64):
    """Splits rows into patterns of up to `size` rows; the first pattern row always names its
    instrument so each pattern can be played on its own."""
    pats = []
    current = None
    for i, r in enumerate(rows):
        if r[1]:
            current = r[1]
        if i % size == 0 and r[0] < EMPTY and not r[1] and current:
            r[1] = current
    for i in range(0, len(rows), size):
        pats.append(song.pattern([tuple(r) for r in rows[i:i + size]]))
    return pats


def build():
    old = open(SNG, 'rb').read()
    song = Song(old[4:100])

    # Instruments (see the module docstring for the WSG-to-SID matching).
    # Legato: no gateoff or hard restart, and the 1st-frame "wave" $FF only sets the gate, so
    # a note after a rest attacks while a note after a note just changes pitch.
    legato = dict(gate=0xC1, first=0xFF)
    # Plucked notes are legato too, but their wavetable closes the gate for the note's first
    # frame and reopens it, so every note re-attacks at its own pitch and sounds for all but
    # one frame of its row (a hard restart would cost two frames).
    pluck_pulse = [(0x40, 0x00), (0x41, 0x00)]
    flat_p37 = song.instrument('ARC FLAT P37', 0x00, 0x70, [(0x41, 0x00)], 0x600, **legato)
    flat_p25 = song.instrument('ARC FLAT P25', 0x00, 0x70, [(0x41, 0x00)], 0x400, **legato)
    echo1 = song.instrument('ARC ECHO 1', 0x00, 0x60, [(0x41, 0x00)], 0x600, **legato)
    echo2 = song.instrument('ARC ECHO 2', 0x00, 0x40, [(0x41, 0x00)], 0x600, **legato)
    flat_sq = song.instrument('ARC FLAT SQ', 0x00, 0x90, [(0x41, 0x00)], 0x800, **legato)
    pluck_sq = song.instrument('ARC PLUCK SQ', 0x04, 0x00, pluck_pulse, 0x800, **legato)
    pluck_sq_long = song.instrument('ARC PLUCK SQ LNG', 0x07, 0x00, pluck_pulse, 0x800, **legato)
    # The 1st-place tune's wave 5 matches a 37.5% pulse nearly as well as a sawtooth, and the
    # pulse keeps that tune as loud against the rest as it is in the arcade.
    pluck_p37 = song.instrument('ARC PLUCK P37', 0x06, 0x00, pluck_pulse, 0x600, **legato)
    pluck_p37_long = song.instrument('ARC PLUCK P37 LG', 0x08, 0x00, pluck_pulse, 0x600, **legato)
    stab_p37 = song.instrument('ARC STAB P37', 0x03, 0x00, pluck_pulse, 0x600, **legato)
    # The 2nd-5th place tune's chords hold flat for 99 ms, then fade out over 83 ms. Its wave 5
    # (fundamental plus octaves) is matched closer by a 37.5% pulse than by a sawtooth, whose
    # extra harmonics roughen the chords. The wavetable re-attacks, holds the gate for 5 frames
    # and closes it. Attack, decay and release share one rate, so a re-attack after a fade is
    # never held up by the SID's envelope counter wrapping (the ADSR delay bug); wavetable
    # delays or an SR command would avoid that too but add about 90 bytes of player code.
    hold_p37 = song.instrument('ARC HOLD P37', 0x33, 0x83,
                               [(0x40, 0x00)] + [(0x41, 0x00)] * 5 + [(0x40, 0x00)], 0x600, **legato)
    # Its held line, WSG wave 3 (fundamental and an equally strong 3rd harmonic only), is a
    # square one sustain step below the chords. That puts it 3.4 dB above them (A-weighted, in
    # VICE) against the arcade's 3.7; at equal levels the square's upper harmonics swamp them.
    soft_sq = song.instrument('ARC SOFT SQ', 0x00, 0x70, [(0x41, 0x00)], 0x800, **legato)
    # Perfect runs on 2-frame rows, where a hard restart would leave a 1-row note only its
    # silent test-bit frame, so its accented voices are legato too (attack after each rest).
    accent_saw = song.instrument('ARC ACCENT SAW', 0x03, 0xB1, [(0x21, 0x00)], **legato)
    accent_sq = song.instrument('ARC ACCENT SQ', 0x03, 0xB1, [(0x41, 0x00)], 0x800, **legato)

    def arp(notes, wave):
        rows = []
        for n, f in zip(notes.split(), BEAM_FRAMES):
            rows += [(wave, 0x80 + note(n))] * f
        return rows
    beam = song.instrument('ARC BEAM', 0x00, 0xD0, arp(BEAM, 0x41), 0x200, loop=True, **legato)
    catch = song.instrument('ARC BEAM CATCH', 0x00, 0xF0, arp(BEAM_CATCH, 0x11), loop=True, **legato)
    drone = song.instrument('ARC DRONE', 0x00, 0xF0, [(0x11, 0x00)], **legato)
    global REST
    # Its wavetable closes the gate on the rest row's first frame (a keyoff, or 1st-frame $FE,
    # would act a frame early, at the note fetch) and keeps the pitch.
    REST = song.instrument('ARC REST', 0x00, 0x00, [(0x20, 0x80)], gate=0xC1, first=0x00)

    empty = song.pattern([(EMPTY, 0, 0, 0)] * 64)

    def tune(voices, grid, total_ticks, loop=False):
        """voices: [(text, instrument)] on a shared grid. Plays once, then silence, unless loop."""
        total = grid.row(total_ticks)
        orders = []
        for k, (text, ins) in enumerate(voices):
            rows = voice_rows(text, ins, grid, total)
            if k == 0:
                tempo_commands(song, grid, rows)
            pats = split(song, rows)
            orders.append(pats + [0xFF, 0] if loop else pats + [empty, 0xFF, len(pats)])
        return orders

    # Subtune 0: game start ($0B). 12-tick rows (5 frames), the last bar in 16-tick rows.
    start_grid = Grid([(0, 12, 5), (672, 16, (7, 6))])
    song.orders.append(tune([(START_V0, flat_p37), (START_V1, flat_p25), (START_V2, flat_p37)],
                            start_grid, 832))

    # Subtune 1: hi-score entry for 2nd-5th place ($10), looping.
    hs2_grid = Grid([(0, 12, 5), (288, 16, (7, 6)), (384, 12, 5), (672, 16, (7, 6))])
    song.orders.append(tune([(HISCORE2_V0, hold_p37), (HISCORE2_V1, hold_p37), (HISCORE2_V2, soft_sq)],
                            hs2_grid, 768, loop=True))

    # Subtune 2: challenging stage result ($0E): the start-theme melody as a 3-voice canon,
    # each voice 32 ticks behind the previous one at volume 10, 9 and 6.
    song.orders.append(canon(song, empty, [flat_p37, echo1, echo2]))

    # Subtune 3: perfect ($14). 5-tick rows: tempo 2 through funktempo 2/2.
    perfect_grid = Grid([(0, 5, (2, 2))])
    song.orders.append(tune([(PERFECT_V0, accent_saw), (PERFECT_V1, accent_sq), (PERFECT_V2, flat_sq)],
                            perfect_grid, 580))

    # Subtune 4: hi-score entry for 1st place ($0C), 10-tick rows (4 frames). Every second
    # repeat starts with the 3-stab tail ($16) over its first 30 ticks instead of the tune's
    # first 3 rows: head, body, head, body, tail, body, head, body, tail, body ...
    hs1_grid = Grid([(0, 10, 4)])
    voices = [(HISCORE1_V0, pluck_p37), (HISCORE1_V1, pluck_p37), (HISCORE1_V2, pluck_p37_long)]
    orders = []
    for k, (text, ins) in enumerate(voices):
        a = voice_rows(text, ins, hs1_grid, 64)
        tail = voice_rows(HISCORE1_TAIL[k], stab_p37 if k < 2 else pluck_p37, hs1_grid, 3)
        next(r for r in a[3:] if r[0] < EMPTY)[1] = ins      # body names its instrument
        if k == 0:
            tempo_commands(song, hs1_grid, a)
            tail[0][2], tail[0][3] = a[0][2], a[0][3]
        head, body, tl = (song.pattern([tuple(r) for r in rows]) for rows in (a[:3], a[3:], tail))
        orders.append([head, body, head, body, tl, body, 0xFF, 2])
    song.orders.append(orders)

    # Subtune 5: blank.
    song.orders.append([[empty, 0xFF, 0]] * 3)

    # Subtunes 6 and 7: fighter captured ($09) and rescued ($11), looping.
    cap_grid = Grid([(0, 12, 5)])
    song.orders.append(tune([(CAPTURED_V0, pluck_sq), (CAPTURED_V1, pluck_sq), (CAPTURED_V2, pluck_sq_long)],
                            cap_grid, 384, loop=True))
    song.orders.append(tune([(RESCUED_V0, pluck_sq), (RESCUED_V1, pluck_sq), (RESCUED_V2, pluck_sq_long)],
                            cap_grid, 384, loop=True))

    # Subtune 8: formation drone ($00) on voice 1, looping; voice 2 sets tempo 7 once.
    tempo7 = song.pattern([(EMPTY, 0, 0xF, 7)] + [(EMPTY, 0, 0, 0)] * 15)
    song.orders.append([[drone_pattern(song, drone), 0xFF, 0], [tempo7, empty, 0xFF, 1],
                        [empty, 0xFF, 0]])

    # Subtunes 9-11: tractor beam (9 is an unused copy of 11), voice 1 only. The instrument's
    # wavetable plays the 8-note figure (13 frames); a 1-row pattern at tempo 13 re-strikes
    # the legato note once per figure, so the loop is seamless and comes back by itself if a
    # sound effect ever takes the voice.
    def held(ins):
        return song.pattern([(0x60 + note('C-4'), ins, 0xF, sum(BEAM_FRAMES) + 1)])
    beam_pat, catch_pat = held(beam), held(catch)
    for p in (beam_pat, catch_pat, beam_pat):
        song.orders.append([[p, 0xFF, 0], [empty, 0xFF, 0], [empty, 0xFF, 0]])
    return song


def canon(song, empty, instruments):
    """Arcade $0E: d_08A0 on all voices, voice k starting 32*k ticks late. Channel-local tempo
    commands ($8x) give each voice its own delay and its own 7/6 rows for the 16-tick bar."""
    orders = []
    for k, ins in enumerate(instruments):
        evs = events(START_V0)
        rows = []
        if k:
            rows.append([EMPTY, 0, 0xF, 0x80 + round(32 * k * 50 / TICK_HZ)])
        first = True
        for t, n, ticks in evs:
            per = 16 if ticks == 16 or (n is None and t >= 768) else 12
            count = ticks // per
            for i in range(count):
                row = [EMPTY, 0, 0, 0]
                if i == 0:
                    row[0] = KEYOFF if n is None else 0x60 + n
                    if first:
                        row[1] = ins
                        first = False
                if per == 16:
                    row[2], row[3] = 0xF, 0x87 if len(rows) % 2 == 0 else 0x86
                rows.append(row)
        # tempo: voice 0 sets 5 for everyone, delayed voices set their own 5 after the delay
        if k == 0:
            rows[0][2], rows[0][3] = 0xF, 5
        else:
            rows[1][2], rows[1][3] = 0xF, 0x85
        pats = split(song, rows)
        orders.append(pats + [empty, 0xFF, len(pats)])
    return orders


def drone_pattern(song, ins):
    """Two 7-frame rows per 34-tick segment, the last segment of each direction half as long.
    Portamento runs on 6 of every 7 frames (the player skips tick 0)."""
    rows = []
    for table, cmd in ((DRONE_UP, 0x1), (DRONE_DOWN, 0x2)):
        for i, (start, inc) in enumerate(table):
            ticks = 34 if i < 7 else 18
            nrows = 2 if i < 7 else 1
            lo_hz = (start + inc) / 256 * 96000 * 16 / (1 << 20)
            hi_hz = (start + inc * ticks) / 256 * 96000 * 16 / (1 << 20)
            n = round(12 * math.log2(lo_hz / 440.0)) + 57
            sid_start = 440.0 * 2 ** ((n - 57) / 12)
            # glide from the note to where the arcade sweep ends
            delta = abs(hi_hz - sid_start) * 16777216 / 985248
            speed = round(delta / (6 * nrows))
            idx = song.speed(speed >> 8, speed & 0xFF)
            rows.append((0x60 + n, ins if not rows else 0, cmd, idx))
            for _ in range(nrows - 1):
                rows.append((EMPTY, 0, cmd, idx))
    return song.pattern(rows)


def pack(sng, sid, reloc):
    r = subprocess.run([reloc, sng, sid, '-W60', '-Zfc', '-D1', '-E1', '-O0'],
                       capture_output=True, text=True)
    if not os.path.exists(sid):
        raise SystemExit('gt2reloc failed:\n' + r.stdout + r.stderr)
    data = bytearray(open(sid, 'rb').read())
    data[0x77] = 0x24        # PAL, 8580: the flags the original GoatTracker export had
    open(sid, 'wb').write(bytes(data))
    return len(data) - 0x7C - 2


if __name__ == '__main__':
    reloc = sys.argv[1] if len(sys.argv) > 1 else GT2RELOC
    song = build()
    song.save(SNG)
    if os.path.exists(SID):
        os.remove(SID)
    size = pack(SNG, SID, reloc)
    print('galaga.sng: %d patterns, %d instruments; galaga.sid: $6000-$%04x (%d bytes)'
          % (len(song.patterns), len(song.instr), 0x6000 + size - 1, size))
