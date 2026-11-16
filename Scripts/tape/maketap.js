// maketap.js <loader dir> <game.prg> <out.tap> [out.wav] [picture.kla] : the game on tape
//
// A standard KERNAL file first, both copies of each block as the KERNAL writes them: its
// header block carries the turbo loader's main part (turbo_high.bin: the 171 bytes after
// the name, the cassette buffer from $0351), its data block the rest (turbo_low.bin:
// $02A7 up to and including BASIC's main loop vector at $0302, which points at the loader).
// Then blocks in the loader's format (tape/turbo_loader.asm): short pulses 0, long ones 1,
// bytes the top bit first; each a pilot of PILOT bytes, the countdown 9 - 1, the start, end
// (not included) and run address, the bytes and their XOR. With the loader's stage 2 (a
// stage2.prg in the loader dir: tape/stage2.asm, with the loading tune) that's the first,
// run at its start: it loads the rest with the tune playing. With a picture (a Koala file:
// bitmap, screen, colours, background) its background, screen and colours go next, the
// last of them running RUN_SHOW_PICTURE, then the bitmap, drawing in on screen; the game
// always last, run at its SYS (the exomizer decruncher's). LOAD or SHIFT + RUN/STOP loads it.
//
// The .tap is version 1 (a pulse = the time between falling edges / 8 cycles, PAL). The .wav
// (44.1 kHz, 8 bit) plays the same pulses as square waves, low then high, so the falling
// edges come where the pulses meet, as the C64 measures them.

'use strict';
const fs = require('fs');
const path = require('path');

const [loaderDir, prgFile, tapFile, wavFile, pictureFile] = process.argv.slice(2);
if (!tapFile) { console.error('usage: node maketap.js <loader dir> game.prg out.tap [out.wav] [picture.kla]'); process.exit(1); }

const NAME = 'GALAGA';
const TURBO_LOW = 0x02a7;					// (turbo_loader.asm)
const BASIC_MAIN_VECTOR = 0x0302;
const HEADER_SPARE = 171;					// header bytes 21 - 191
const PROGRAM_HEADER = 3;					// a program loaded where its header says

// KERNAL pulses (PAL), its leaders and gaps (short pulses)
const SHORT = 0x30, MEDIUM = 0x42, LONG = 0x56;
const HEADER_LEADER = 0x6a00, DATA_LEADER = 0x1a00, GAP = 0x4f, TRAILER = 0x4e;

// the turbo loader's pulses (264 and 528 cycles: turbo_loader.asm's THRESHOLD is between),
// its first pilot long (the motor starting), the others enough for the work between blocks
const TURBO_0 = 0x21, TURBO_1 = 0x42;
const PILOT = 0x02, FIRST_PILOT = 1000, PILOT_BYTES = 128, COUNTDOWN = 9, TURBO_TRAILER = 200;
const RUN_NEXT = 0, RUN_SHOW_PICTURE = 1;

// the loading picture's places (turbo_loader.asm)
const PICTURE_SCREEN = 0xc000, PICTURE_BITMAP = 0xe000, COLOUR_RAM = 0xd800, BACKGROUND = 0xd021;
const KOALA_LOAD = 0x6000, KOALA_SIZE = 10001;

const PAL_CLOCK = 985248, SAMPLE_RATE = 44100;

const high = fs.readFileSync(path.join(loaderDir, 'turbo_high.bin'));
const stage2File = path.join(loaderDir, 'stage2.prg');
const stage2 = fs.existsSync(stage2File) ? fs.readFileSync(stage2File) : null;
const low = fs.readFileSync(path.join(loaderDir, 'turbo_low.bin'));
if (high.length > HEADER_SPARE) throw new Error(`the turbo loader's main part is ${high.length} bytes, the header has room for ${HEADER_SPARE}`);
if (TURBO_LOW + low.length !== BASIC_MAIN_VECTOR + 2) throw new Error(`turbo_low.bin must run from $${TURBO_LOW.toString(16)} to the main loop vector`);

const prg = fs.readFileSync(prgFile);
const start = prg[0] | prg[1] << 8, bytes = prg.subarray(2);
const run = sysAddress(prg);

const pulses = [];							// TAP units; a number over 255 is a pause in cycles

// the KERNAL's format: a byte is a marker (long, medium), 8 bits low first (0 = short, medium;
// 1 = medium, short) and an odd parity bit; a block its leader, a countdown ($89 - $81 for the
// first copy, $09 - $01 for the second), the bytes, their XOR and an end marker (long, short)

function kernalBit(b) { pulses.push(...(b ? [MEDIUM, SHORT] : [SHORT, MEDIUM])); }
function kernalByte(v) {
	pulses.push(LONG, MEDIUM);
	let parity = 1;
	for (let i = 0; i < 8; i++) { const b = (v >> i) & 1; kernalBit(b); parity ^= b; }
	kernalBit(parity);
}
function shorts(n) { for (let i = 0; i < n; i++) pulses.push(SHORT); }
function kernalCopy(payload, first) {
	for (let c = 9; c >= 1; c--) kernalByte(first ? 0x80 | c : c);
	let check = 0;
	for (const v of payload) { kernalByte(v); check ^= v; }
	kernalByte(check);
	pulses.push(LONG, SHORT);
}
function kernalBlock(payload, leader) {
	shorts(leader);
	kernalCopy(payload, true);
	shorts(GAP);
	kernalCopy(payload, false);
	shorts(TRAILER);
}

// the header block: type, start, end, the name (16, padded with spaces), the loader's main
// part; the data block: the rest of it and the vector

const header = new Uint8Array(192).fill(0x20);
header[0] = PROGRAM_HEADER;
header[1] = TURBO_LOW & 255; header[2] = TURBO_LOW >> 8;
header[3] = (BASIC_MAIN_VECTOR + 2) & 255; header[4] = (BASIC_MAIN_VECTOR + 2) >> 8;
for (let i = 0; i < NAME.length; i++) header[5 + i] = NAME.charCodeAt(i);
header.set(high, 21);

kernalBlock(header, HEADER_LEADER);
kernalBlock(low, DATA_LEADER);

// the turbo blocks

function turboByte(v) { for (let i = 7; i >= 0; i--) pulses.push((v >> i) & 1 ? TURBO_1 : TURBO_0); }
let first = true;
function turboBlock(at, data, runAddress) {
	const end = at + data.length;
	for (let i = 0; i < (first ? FIRST_PILOT : PILOT_BYTES); i++) turboByte(PILOT);
	first = false;
	for (let c = COUNTDOWN; c >= 1; c--) turboByte(c);
	for (const v of [at & 255, at >> 8, end & 255, end >> 8, runAddress & 255, runAddress >> 8]) turboByte(v);
	let check = 0;
	for (const v of data) { turboByte(v); check ^= v; }
	turboByte(check);
}

if (stage2) {
	const at = stage2[0] | stage2[1] << 8, code = stage2.subarray(2);
	if (at + code.length > start && at < start + bytes.length) throw new Error(`stage 2 ($${at.toString(16)} - $${(at + code.length - 1).toString(16)}) is under the game`);
	turboBlock(at, code, at);
}

if (pictureFile) {
	let koala = fs.readFileSync(pictureFile);
	if (koala.length === KOALA_SIZE + 2 && (koala[0] | koala[1] << 8) === KOALA_LOAD) koala = koala.subarray(2);
	if (koala.length !== KOALA_SIZE) throw new Error(`${pictureFile}: a Koala picture is ${KOALA_SIZE} bytes (+ 2 for its load address)`);
	turboBlock(BACKGROUND, koala.subarray(10000, 10001), RUN_NEXT);
	turboBlock(PICTURE_SCREEN, koala.subarray(8000, 9000), RUN_NEXT);
	turboBlock(COLOUR_RAM, koala.subarray(9000, 10000), RUN_SHOW_PICTURE);
	turboBlock(PICTURE_BITMAP, koala.subarray(0, 8000), RUN_NEXT);
}

turboBlock(start, bytes, run);
for (let i = 0; i < TURBO_TRAILER; i++) pulses.push(TURBO_0);

// the .tap

const data = [];
for (const p of pulses) {
	if (p < 256) data.push(p);
	else data.push(0, p & 255, (p >> 8) & 255, (p >> 16) & 255);
}
const tap = Buffer.alloc(20 + data.length);
tap.write('C64-TAPE-RAW', 0, 'latin1');
tap[12] = 1;
tap.writeUInt32LE(data.length, 16);
Buffer.from(data).copy(tap, 20);
fs.writeFileSync(tapFile, tap);

let cycles = 0;
for (const p of pulses) cycles += p < 256 ? p * 8 : p;
console.log(`${tapFile}: ${bytes.length} bytes $${start.toString(16)} - $${(start + bytes.length - 1).toString(16)}, run $${run.toString(16)}${stage2 ? `, stage 2 and the tune (${stage2.length - 2} bytes) first` : ''}${pictureFile ? `, the picture ${stage2 ? 'next' : 'first'}` : ''}; ${(cycles / PAL_CLOCK).toFixed(0)} seconds of tape`);

// the .wav: each pulse low then high, its time kept exact over the whole tape (rounded per edge)

if (wavFile) {
	const LOW = 0x20, HIGH = 0xe0;
	const samples = Buffer.alloc(Math.ceil(cycles / PAL_CLOCK * SAMPLE_RATE) + SAMPLE_RATE);
	let at = 0, written = 0;
	const fillTo = (cycle, level) => { const upto = Math.round(cycle / PAL_CLOCK * SAMPLE_RATE); while (written < upto) samples[written++] = level; };
	fillTo(PAL_CLOCK / 2, HIGH);			// half a second of quiet (high: no edge) first
	at = PAL_CLOCK / 2;
	for (const p of pulses) {
		const length = p < 256 ? p * 8 : p;
		fillTo(at + length / 2, LOW);
		fillTo(at + length, HIGH);
		at += length;
	}
	fillTo(at + PAL_CLOCK / 2, HIGH);
	const pcm = samples.subarray(0, written);
	const wav = Buffer.alloc(44 + pcm.length);
	wav.write('RIFF', 0, 'latin1'); wav.writeUInt32LE(36 + pcm.length, 4); wav.write('WAVE', 8, 'latin1');
	wav.write('fmt ', 12, 'latin1'); wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20); wav.writeUInt16LE(1, 22);
	wav.writeUInt32LE(SAMPLE_RATE, 24); wav.writeUInt32LE(SAMPLE_RATE, 28); wav.writeUInt16LE(1, 32); wav.writeUInt16LE(8, 34);
	wav.write('data', 36, 'latin1'); wav.writeUInt32LE(pcm.length, 40);
	pcm.copy(wav, 44);
	fs.writeFileSync(wavFile, wav);
	console.log(`${wavFile}: ${(pcm.length / SAMPLE_RATE).toFixed(0)} seconds, ${SAMPLE_RATE} Hz`);
}

// the address the prg's BASIC line SYSes to (an exomizer sfx: 10 SYS 2061)

function sysAddress(p) {
	const SYS = 0x9e;
	for (let i = 6; i < Math.min(p.length, 40); i++) if (p[i] === SYS) {
		let digits = '';
		for (let j = i + 1; j < p.length && p[j] !== 0; j++) if (p[j] >= 0x30 && p[j] <= 0x39) digits += String.fromCharCode(p[j]);
		if (digits) return +digits;
	}
	throw new Error(`${prgFile}: no SYS in its BASIC line`);
}
