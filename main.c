#include <SDL2/SDL.h>
#include <bits/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "lissajous.h"
#include <time.h>

#define M_PI    3.14159265358979323846	/* pi */
#define M_2xPI  2*M_PI

// TODO: move to Raylib
// TODO: add sliders
// TODO: add function resp. for displaying info in console and print everything
int main(int argc, char* argv[]) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window* window = NULL;
    window = SDL_CreateWindow("Lissajous Curves", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Renderer *renderer = NULL;
    renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED );

    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, WIDTH, HEIGHT);

    uint32_t *pixelBuffer = (uint32_t*) malloc( WIDTH * HEIGHT * sizeof(uint32_t) );
    float A = 200.0, B = 200.0;
    float a = 2.0, b = 3.0;
    float delta = 0.0;
    // int test_index = 300 * WIDTH + 400;
    // int test_color = 0xF00000;

    SDL_Event e;
    bool quit = false;

    // for benchmarking
    struct timespec start, end;

    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            } else if (e.type == SDL_KEYDOWN) {
                // Interactive parameter modification
                switch (e.key.keysym.sym) {
                    case SDLK_UP:    a += 1; break;
                    case SDLK_DOWN:  a -= 1; break;
                    case SDLK_RIGHT: b += 1; break;
                    case SDLK_LEFT:  b -= 1; break;
                    case SDLK_w:     A += 1;   break;
                    case SDLK_s:     A -= 1;   break;
                    case SDLK_d:     B += 1;   break;
                    case SDLK_a:     B -= 1;   break;
                    case SDLK_SPACE:
                        A = 200.0, B = 200.0;
                        a = 1.0, b = 1.0;
                        break;
                    case SDLK_RALT:
                        A = 200.0, B = 200.0;
                        a = 1.0, b = 110.0;
                        break;
                }
            }
        }
        if (A >= WIDTH / 2.0) A = WIDTH / 2.0 - 1;
        if (A <= -WIDTH / 2.0) A = -WIDTH / 2.0 + 1;
        if (B >= HEIGHT / 2.0) B = HEIGHT / 2.0 - 1;
        if (B <= -HEIGHT / 2.0) B = -HEIGHT / 2.0 + 1;

        memset(pixelBuffer, 0, WIDTH * HEIGHT * sizeof(uint32_t));
        // ==============
        delta += 0.00075; // Animate the curve by changing delta over time (affects speed)
        if (delta >= M_2xPI) delta = 0;


        clock_gettime(CLOCK_MONOTONIC, &start);
        lissajousAVX(pixelBuffer, WIDTH, HEIGHT, A, B, a, b, delta / (2.0f * M_PI));
        clock_gettime(CLOCK_MONOTONIC, &end);
        double lissajous_duration = end.tv_nsec - start.tv_nsec;

        printf("a: %.2f, b: %.2f, A: %.2f, B: %.2f, delta: %.4f, lissajous_time: %.4fµs  $$$\r",
               a, b, A, B, delta, lissajous_duration / 1000.0);

        SDL_UpdateTexture(texture, NULL, pixelBuffer, WIDTH * sizeof(uint32_t));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }


    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    free(pixelBuffer);
    return 0;
}
