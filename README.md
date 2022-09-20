# msdos-ascii-paint
MS-DOS program for painting with ASCII characters.

This was written as a hobby project, since MS-DOS is kinda outdated.

## Contributions

Please feel free to contribute to this repository! Anything helps, and it helps me learn from my mistakes.

## Installation

This 8086 assembly was written to be used with the NASM compiler, so make sure to download and install that.
You will need to compile the source code:

<sup>nasm.exe -f bin -o paint paint.asm</sup>

Then, run the program by typing out its name in the terminal:

<sup>paint</sup>

You are ready to go!

## Controlls

W,A,S,D:  Directional cursor control.__
N,M:      Cycle colors (0x00 - 0xFF).__
X:        Exits program.__
Q:        Opens character selection screen; Select with ENTER.__
V:        Allows you to paste full string.__
          NOTE: I never finished this feautere. Expect errors!
