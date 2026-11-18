"""Builds the arcade-style GoatTracker sound effects (.sfx) imported by Scripts/common/sfx.asm.

Run from anywhere:  python arcade_sfx.py   (writes the .sfx files next to this script)

GoatTracker 2 sfx format, as played by the routine in galaga.sid:
    byte 0  attack/decay
    byte 1  sustain/release
    byte 2  pulse width: $0N gives $N0N, so $04 = 25%, $02 = 12.5%, $06 = 37.5%, $08 = 50%
    then one step per frame (50 Hz): a note byte ($80 + GoatTracker note, A-4 = $b9),
    optionally followed by a waveform byte ($01-$81), and $00 to end (waveform 0 = silence).
The player spends two frames (hard restart, then test bit + gate) before the first step.

Arcade reference: the Galaga sound CPU ROM (gg1-7) runs its effects at 121 Hz (two NMIs per
video frame), each note lasting a whole number of those ticks, on a 3-voice Namco WSG with
32-sample 4-bit waveforms. Arcade notes sit about 40 cents sharp of A440; they are rounded to
the nearest semitone here. The WSG waveforms are matched on spectrum: wave 6 ~ 25% pulse,
wave 4 ~ 12.5% pulse, wave 7 ~ 37.5% pulse, wave 5 ~ sawtooth, wave 3 ~ square.
Fast runs of 16.5 ms arcade notes are thinned to one note per 20 ms frame so that each effect
keeps the arcade length and rhythm. Levels follow the arcade balance between effects but keep
the shot at its previous loudness; coin and extra ship use a 25% pulse because the arcade
plays them as 3-voice chords.
"""
import os

NAMES = ['C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-']

TRI, SAW, PULSE, NOISE, GATE = 0x10, 0x20, 0x40, 0x80, 0x01


def note(name):
    """'A-4' -> GoatTracker note number (57)."""
    return NAMES.index(name[:2]) + 12 * int(name[2:])


def name_of(n):
    return '%s%d' % (NAMES[n % 12], n // 12)


def transpose(name, semitones):
    return name_of(note(name) + semitones)


class Sfx:
    def __init__(self, ad, sr, pw, wave):
        self.ad, self.sr, self.pw, self.wave = ad, sr, pw, wave
        self.frames = []          # (note number, waveform byte)

    def play(self, notes, frames=1):
        """Each note held for `frames` frames (an int, or a list matching `notes`)."""
        counts = frames if isinstance(frames, list) else [frames] * len(notes.split())
        for name, count in zip(notes.split(), counts):
            self.frames += [(note(name), self.wave | GATE)] * count
        return self

    def rest(self, frames=1):
        """Gate off on the last note: with release 0 this is silence within 6 ms."""
        self.frames += [(self.frames[-1][0], self.wave)] * frames
        return self

    def data(self):
        out = [self.ad, self.sr, self.pw]
        wave = None
        for n, w in self.frames:
            out.append(0x80 + n)
            if w != wave:
                out.append(w)
                wave = w
        out.append(0)
        return bytes(out)


def challenge_voice(chord_note):
    """Arcade $0D (challenging stage start), one voice per file, wave 3 at 107 ms a beat:
    chord 2 beats, rest 1, then 1, 1, 1 and 3 beats rising D, D#, F, G (major chords)."""
    up = [chord_note, chord_note, transpose(chord_note, 1), transpose(chord_note, 3),
          transpose(chord_note, 5)]
    s = Sfx(0x04, 0x91, 0x08, PULSE)
    s.play(up[0], 11).rest(5)
    s.play(' '.join(up[1:]), [5, 5, 6, 16])
    return s


def build():
    sfx = {}

    # Player shot, arcade $0F: 40 chromatic steps down from C-7 to A-3, one per 8.25 ms tick
    # (330 ms), wave 6, constant volume, cut dead. One frame samples every 2.4 ticks.
    shot = Sfx(0x00, 0x50, 0x04, PULSE)
    for f in range(17):
        shot.frames.append((note('C-7') - int(f * 20 / 8.25), PULSE | GATE))
    sfx['fire4'] = shot

    # Dive, arcade $13: the same C-7 to A-3 sweep, 49.5 ms per semitone (1.98 s), wave 6.
    dive = Sfx(0x00, 0x60, 0x04, PULSE)
    for f in range(99):
        dive.frames.append((note('C-7') - int(f * 20 / 49.5), PULSE | GATE))
    sfx['dive'] = dive

    # Butterfly (red) kill, arcade $02, wave 4: D major scale up D-4..D-5, a 99 ms gap,
    # then chromatic down A#4..F-4, every note 16.5 ms.
    sfx['hit1'] = (Sfx(0x00, 0xf0, 0x02, PULSE)
                   .play('D-4 E-4 F#4 G-4 A-4 B-4 C#5 D-5').rest(4)
                   .play('A#4 A-4 G#4 G-4 F#4 F-4'))

    # Bee (yellow) kill, arcade $03, wave 6: G-4 up to B-4 and chromatic down to E-4,
    # 66 ms gap, then C-4 up to E-4 and chromatic down to A-3 (446 ms).
    sfx['hit2'] = (Sfx(0x00, 0x80, 0x04, PULSE)
                   .play('G-4 A-4 B-4 A#4 A-4 G#4 G-4 F#4 E-4').rest(3)
                   .play('C-4 D-4 E-4 D#4 D-4 C#4 C-4 B-3 A#3 A-3'))

    # Boss first hit (green boss), arcade $04, wave 5: three rising chromatic triplets with
    # 16.5 ms gaps, G-4 G#4 A-4 / A#4 B-4 C-5 / C#5 D-5 D#5 (182 ms).
    sfx['hit3'] = (Sfx(0x00, 0xf0, 0x00, SAW)
                   .play('G-4 A-4').rest().play('A#4 C-5').rest().play('C#5 D#5 D#5'))

    # Boss kill (blue boss), arcade $01, wave 7: the green-boss triplets three times, starting
    # on D#4, F-4 and G-4, with a 50 ms pause between the runs (644 ms).
    boss = Sfx(0x00, 0xb0, 0x06, PULSE)
    for i, start in enumerate(['D#4', 'F-4', 'G-4']):
        for g in range(3):
            low = transpose(start, 3 * g)
            boss.play(low + ' ' + transpose(low, 2))
            if g < 2:
                boss.rest()
        if i < 2:
            boss.rest(3)
    boss.play('D#5')
    sfx['hit4'] = boss

    # Transform (bonus bee), arcade $12, wave 4: G-4 A-4 G-4 A-4 C-5 D-5 C-5 D-5, 66 ms each.
    sfx['transform'] = (Sfx(0x00, 0xd0, 0x02, PULSE)
                        .play('G-4 A-4 G-4 A-4 C-5 D-5 C-5 D-5', [3, 3, 4, 3, 3, 4, 3, 3]))

    # Stage badge click, arcade $15, wave 7: B-5, gap, G-5, gap, A-5, 16.5 ms each.
    sfx['badge'] = (Sfx(0x00, 0xc0, 0x06, PULSE)
                    .play('B-5').rest().play('G-5').rest().play('A-5'))

    # Coin, arcade $08: 3-voice chords, 58 ms each with a 41 ms attack ramp; this is the top
    # voice D-5 E-5 A-5 D-5 E-5 A-5 B-5 (wave 4), re-attacked on every note.
    coin = Sfx(0x40, 0xf0, 0x04, PULSE)
    for n in 'D-5 E-5 A-5 D-5 E-5 A-5'.split():
        coin.play(n, 2).rest()
    coin.play('B-5', 9)
    sfx['coin'] = coin

    # Extra ship, arcade $0A: 3-voice chords, 91 ms each, every note a 41 ms attack then a fade;
    # this is the top voice E-5 D-5 E-5 G-5 B-5 D-6 (wave 4).
    extra = Sfx(0x45, 0x00, 0x04, PULSE)
    for n, length in zip('E-5 D-5 E-5 G-5 B-5'.split(), [5, 4, 5, 4, 5]):
        extra.play(n, length - 1).rest()
    extra.play('D-6', 10)
    sfx['extra'] = extra

    # Challenging stage jingle, arcade $0D: the three voices of D, D#, F and G major chords.
    sfx['c1'] = challenge_voice('D-5')
    sfx['c2'] = challenge_voice('A-4')
    sfx['c3'] = challenge_voice('F#4')

    return sfx


if __name__ == '__main__':
    here = os.path.dirname(os.path.abspath(__file__))
    for name, s in build().items():
        data = s.data()
        with open(os.path.join(here, name + '.sfx'), 'wb') as f:
            f.write(data)
        print('%-10s %3d bytes, %3d frames' % (name, len(data), len(s.frames)))
