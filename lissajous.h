#ifndef LISSAJOUS_H
#define LISSAJOUS_H

#define WIDTH 800
#define HEIGHT 600

// x(t) = Asin(at + delta)
// y(t) = Bsin(bt)
void lissajous(uint32_t* pixelBuffer, int screenWidth, int screenHeight, float amplitudeX, float amplitudeY,
    float freqX, float freqY, float delta);

void lissajousAVX(uint32_t* pixelBuffer, int screenWidth, int screenHeight, float amplitudeX, float amplitudeY,
    float freqX, float freqY, float delta);

void lissajousAVX512(uint32_t* pixelBuffer, int screenWidth, int screenHeight, float amplitudeX, float amplitudeY,
    float freqX, float freqY, float delta);


#endif // LISSAJOUS_H
