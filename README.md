### Lissajous curves (x86-64 assembly)
The project is a hybrid C and assembly program which animates [lissajous curves](https://en.wikipedia.org/wiki/Lissajous_curve) and lets a user interact with them by adjusting parameters (A, B, a, b) in real time.

It's split in two main parts:
1. C code `main.c` handles user's input, memory allocation and graphics rendering using the [SDL2 library](https://www.libsdl.org/),

2. Assembly code `lissajous.s` performs the mathematical calculations for generating the Lissajous curves:

    x(t) = A * sin(a * t + δ/2π)

    y(t) = B * sin(b * t)

It computes the coordinates (x, y) for every `dt = 0.00025` in `[0.0, 1.0]` using the sine function approximated by a 9th degree [minimax polynomial](https://mathworld.wolfram.com/ChebyshevPolynomialoftheFirstKind.html), which coefficients were computed* using the [Remez algorithm](https://www.boost.org/doc/libs/latest/libs/math/doc/html/math_toolkit/remez.html) and uses the SSE vector instructions, instead of x87 FPU, for performing 4 single-precision floating point calculations simultaneously to achieve better performance (which can be improved even more by using AVX/AVX-512).

The program is designed to run on Linux operating systems and follows the [Unix System V x86-64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI) for compatibility.
This project demonstrates how to combine low-level assembly programming with high-level graphics rendering to create visually appealing results.


#### Requirements:
- x86-64 compatible CPU
- Linux operating system (tested on Ubuntu 24.04.4 LTS)
- SDL2 development libraries

    `sudo apt install libsdl2-dev` for Debian-based distributions

    detailed guide is [here](https://wiki.libsdl.org/SDL2/Installation)


#### For building
- NASM assembler
- Make utility
- GCC compiler (for linking)


#### Huge thanks to
- [Lasse](https://gist.github.com/publik-void) for computing the coefficients for the sine approximations using the Remez algorithm:
[Fast MiniMax Polynomial Approximations of Sine and Cosine](https://publik-void.github.io/sin-cos-approximations/#_sin_abs_error_minimized_degree_9)
- gdb