//
//  Video.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 10/09/2020.
//

import Foundation
import SDL2

private enum Constants {
    static let windowsName = "CHIP 8 Emulator"
    static let windowsSize: (width: Int32, height: Int32) = (width: 640, height: 320)
    static let textureSize: (width: Int32, height: Int32) = (width: 64, height: 32)
    static let depthColor: Int32 = 32
    static let alphaColor: UInt32 = 0xFF000000
    static let redColor: UInt32 = 0x00FF0000
    static let greenColor: UInt32 = 0x0000FF00
    static let blueColor: UInt32 = 0x000000FF
    static let whiteColor: UInt32 = 0xFFFFFFFF
    static let blackColor: UInt32 = .zero
}

struct Video {
    private let window: OpaquePointer
    private let renderer: OpaquePointer
    private let texture: OpaquePointer
    private var surface: SDL_Surface?
    
    init() {
        self.window = SDL_CreateWindow(Constants.windowsName, Int32(SDL_WINDOWPOS_CENTERED_MASK),
                                       Int32(SDL_WINDOWPOS_CENTERED_MASK),
                                       Constants.windowsSize.width, Constants.windowsSize.height,
                                       SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_OPENGL.rawValue)
        self.renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)
        
        self.texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888.rawValue, Int32(SDL_TEXTUREACCESS_STREAMING.rawValue),
                                         Constants.textureSize.width, Constants.textureSize.height)
        self.surface = SDL_CreateRGBSurface(.zero, Constants.textureSize.width, Constants.textureSize.height,
                                            Constants.depthColor,
                                            Constants.redColor,
                                            Constants.greenColor,
                                            Constants.blueColor,
                                            Constants.alphaColor)?.move()
    }
    
    func render(screenContent: [Bool]) {
        guard var surface = surface else { return }
        
        SDL_LockTexture(texture, nil, &surface.pixels, &surface.pitch)
        let content = surface.pixels?.assumingMemoryBound(to: UInt32.self)
        screenContent.enumerated().forEach { content?[$0] = $1 ? Constants.whiteColor : Constants.blackColor }
        SDL_UnlockTexture(texture)
        refresh()
    }
    
    func finish() {
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(window)
    }
    
    private func refresh() {
        SDL_RenderClear(renderer)
        SDL_RenderCopy(renderer, texture, nil, nil)
        SDL_RenderPresent(renderer)
    }
}
