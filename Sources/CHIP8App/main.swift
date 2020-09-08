//
//  main.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 07/09/2020.
//

import Foundation
import SDL2
import CHIP8

func my_main() {
    let chip8 = CHIP8()
    
    SDL_Init(SDL_INIT_VIDEO)
    let window = SDL_CreateWindow("CHIP 8 Emulator", Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK), 640, 320, SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_OPENGL.rawValue)

    var pixelFormat: UInt32 {
        #if os(Linux)
            return UInt32(SDL_PIXELFORMAT_RGBA8888)
        #else
            return SDL_PIXELFORMAT_RGBA8888.rawValue
        #endif
    }

    let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)
    let texture = SDL_CreateTexture(renderer, pixelFormat, Int32(SDL_TEXTUREACCESS_STREAMING.rawValue), 64, 32)
    guard var surface = SDL_CreateRGBSurface(0, 64, 32, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)?.move()
        else { return }


    var event = SDL_Event()
    var mustQuit: Bool = false
    var lastTick: UInt32 = SDL_GetTicks()
    var cycles: UInt32 = SDL_GetTicks()
    chip8.loadROM()
    while !mustQuit {
        while (SDL_PollEvent(&event) != 0) {
            switch (event.type) {
            case SDL_QUIT.rawValue: mustQuit = true;
            default: break
           }
        }
        
        if (SDL_GetTicks() - cycles > 1) {
            chip8.step()
            cycles = SDL_GetTicks()
        }
        
        if (SDL_GetTicks() - lastTick > (1000/60)) {
            chip8.decreaseTimers()
            
            SDL_LockTexture(texture, nil, &surface.pixels, &surface.pitch)
            let content = surface.pixels?.assumingMemoryBound(to: UInt32.self)
            chip8.screenContent().enumerated().forEach { content?[$0] = ($1 == false) ? .zero : 0xFFFFFFFF }
            SDL_UnlockTexture(texture)
            
            SDL_RenderClear(renderer)
            SDL_RenderCopy(renderer, texture, nil, nil)
            SDL_RenderPresent(renderer)
            lastTick = SDL_GetTicks()
        }
    }

    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    SDL_Quit()

}

my_main()
