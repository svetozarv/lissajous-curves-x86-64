#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "lissajous.h"
#include <math.h>

#define M_2xPI 2*M_PI


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
    float A = 150.0, B = 150.0;
    float a = 1.0, b = 2.0;
    float delta = 0.0;
    // int test_index = 300 * WIDTH + 400;
    // int test_color = 0xF00000;

    SDL_Event e;
    bool quit = false;

    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            } else if (e.type == SDL_KEYDOWN) {
                // Interactive parameter modification
                switch (e.key.keysym.sym) {
                    case SDLK_UP:    a += 0.1; break;
                    case SDLK_DOWN:  a -= 0.1; break;
                    case SDLK_RIGHT: b += 0.1; break;
                    case SDLK_LEFT:  b -= 0.1; break;
                    case SDLK_w:     A += 0.1; break;
                    case SDLK_s:     A -= 0.1; break;
                    case SDLK_d:     B += 0.1; break;
                    case SDLK_a:     B -= 0.1; break;
                }
            }
        }
        if (A >= WIDTH/2) A = WIDTH/2 - 1;
        if (B >= HEIGHT/2) B = HEIGHT/2 - 1;
        printf("a: %.2f, b: %.2f, A: %.2f, B: %.2f\r", a, b, A, B);

        memset(pixelBuffer, 0, WIDTH * HEIGHT * sizeof(uint32_t));
        // ==============
        delta += 0.001; // Animate the curve by changing delta over time
        if (delta >= M_2xPI) delta = 0;

        lissajous(pixelBuffer, WIDTH, HEIGHT, A, B, a, b, delta / (2.0f * M_PI));

        // ==============
        // pixelBuffer[test_index] = test_color;
        // ++test_index;
        // test_color += 5;
        // ==============

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
