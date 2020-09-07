//
//  main.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 07/09/2020.
//

import Foundation
import SDL2

SDL_Init(SDL_INIT_VIDEO)
let window = SDL_CreateWindow("CHIP 8 Emulator", Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK), 640, 320, SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_OPENGL.rawValue)

var pixels: UnsafeMutableRawPointer?
var pitch: Int32 = .zero
var pixelFormat: UInt32 {
    #if os(Linux)
        return UInt32(SDL_PIXELFORMAT_RGBA8888)
    #else
        return SDL_PIXELFORMAT_RGBA8888.rawValue
    #endif
}

let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)
let texture = SDL_CreateTexture(renderer, pixelFormat, Int32(SDL_TEXTUREACCESS_STREAMING.rawValue), 64, 32)

SDL_LockTexture(texture, nil, &pixels, &pitch)

// We need to specify the type of the array
let content = pixels?.assumingMemoryBound(to: UInt8.self)
content?.assign(repeating: 0xFF, count: 32*Int(pitch))
SDL_UnlockTexture(texture)


var ev = SDL_Event()
var mustQuit: Bool = false
while !mustQuit {
    SDL_RenderClear(renderer)
    SDL_RenderCopy(renderer, texture, nil, nil)
    SDL_RenderPresent(renderer)
    SDL_WaitEvent(&ev)
    
    // Exit the app
    mustQuit = SDL_EventType(ev.type) == SDL_QUIT
}

SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
