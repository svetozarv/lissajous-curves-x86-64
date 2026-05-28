#ifndef LISSAJOUS_H
#define LISSAJOUS_H


#define WIDTH 800
#define HEIGHT 600

// x = Asin(at + delta)
// y = Bsin(bt)
void drawLissajous(int width, int height, double A, double B, double a, double b, double delta);


#endif // LISSAJOUS_H