#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "lissajous.h"


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

    // SDL_Surface* screenSurface = NULL;    // image
    // screenSurface = SDL_GetWindowSurface( window );

    SDL_Renderer *renderer = NULL;
    renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED );

    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, WIDTH, HEIGHT);

    uint32_t *pixelBuffer = (uint32_t*) malloc( WIDTH * HEIGHT * sizeof(uint32_t) );
    double A = 300.0, B = 200.0;
    double a = 3.0, b = 2.0;
    double delta = 0.5;
    int test_index = 300 * WIDTH + 400;

    // Fill the surface white
    // SDL_FillRect(screenSurface, NULL, SDL_MapRGB( screenSurface->format, 255, 255, 255 ));
    // SDL_UpdateWindowSurface( window );
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

        // memset(pixelBuffer, 0, WIDTH * HEIGHT * sizeof(uint32_t));
        // ==============
        // drawLissajous(WIDTH, HEIGHT, A, B, a, b, delta);
        // ==============
        pixelBuffer[test_index] = 0x00FF00;
        ++test_index;

        SDL_UpdateTexture(texture, NULL, pixelBuffer, WIDTH * sizeof(uint32_t));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }


    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    free(pixelBuffer);
    return 0;
}
