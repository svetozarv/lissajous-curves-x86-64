#ifndef LISSAJOUS_H
#define LISSAJOUS_H

#define WIDTH 800
#define HEIGHT 600

// x(t) = Asin(at + delta)
// y(t) = Bsin(bt)
void lissajous(uint32_t* pixelBuffer, int width, int height, float A, float B, float a, float b, float delta);


#endif // LISSAJOUS_H
