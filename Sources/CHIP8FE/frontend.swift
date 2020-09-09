//
//  Frontend.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 09/09/2020.
//

import Foundation
import SDL2
import CHIP8

private enum Constants {
    static let keys = [
        SDL_SCANCODE_X, // 0
        SDL_SCANCODE_1, // 1
        SDL_SCANCODE_2, // 2
        SDL_SCANCODE_3, // 3
        SDL_SCANCODE_Q, // 4
        SDL_SCANCODE_W, // 5
        SDL_SCANCODE_E, // 6
        SDL_SCANCODE_A, // 7
        SDL_SCANCODE_S, // 8
        SDL_SCANCODE_D, // 9
        SDL_SCANCODE_Z, // A
        SDL_SCANCODE_C, // B
        SDL_SCANCODE_4, // C
        SDL_SCANCODE_R, // D
        SDL_SCANCODE_F, // E
        SDL_SCANCODE_V, // F
    ]
}

public class MainApp {
    private let chip8: CHIP8
    private var audioSpec: AudioScpec
    private let window: OpaquePointer
    private let renderer: OpaquePointer
    private let texture: OpaquePointer
    private var surface: SDL_Surface?

    public init(chip8: CHIP8 = CHIP8()) {
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)
        self.chip8 = chip8
        self.audioSpec = AudioScpec()
        self.window = SDL_CreateWindow("CHIP 8 Emulator", Int32(SDL_WINDOWPOS_CENTERED_MASK),
                                       Int32(SDL_WINDOWPOS_CENTERED_MASK), 640, 320,
                                       SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_OPENGL.rawValue)
        self.renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)
        
        let pixelFormat: UInt32 = {
            #if LinuxAlternative
                return UInt32(SDL_PIXELFORMAT_RGBA8888)
            #else
                return SDL_PIXELFORMAT_RGBA8888.rawValue
            #endif
        }()
        
        self.texture = SDL_CreateTexture(renderer, pixelFormat, Int32(SDL_TEXTUREACCESS_STREAMING.rawValue), 64, 32)
        self.surface = SDL_CreateRGBSurface(0, 64, 32, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)?.move()

        guard SDL_OpenAudio(&audioSpec.spec, nil) >= .zero else { return }
    }

    public func start(game: Data) {
        guard var surface = surface, chip8.loadROM(data: game) else { return }
        chip8.delegate = self

        var event = SDL_Event()
        var mustQuit: Bool = false
        var lastTick: UInt32 = SDL_GetTicks()
        var cycles: UInt32 = SDL_GetTicks()
        
        while !mustQuit {
            while (SDL_PollEvent(&event) != 0) {
                switch (event.type) {
                case SDL_QUIT.rawValue: mustQuit = true;
                default: break
               }
            }
            
            if (SDL_GetTicks() - cycles > 1) {
                if !chip8.isWaitingKey {
                    chip8.step()
                } else if let key = keyPressed() {
                    chip8.keyPressed(key: key)
                }
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
        
        finishExecution()
    }
}

private extension MainApp {
    func finishExecution() {
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(window)
        SDL_CloseAudio()
        SDL_Quit()
    }
    
    func isKeyPressed(_ key: UInt8) -> Bool {
        guard let sdlKeys = SDL_GetKeyboardState(nil) else { return false }
        return sdlKeys[Int(Constants.keys[Int(key)].rawValue)] != .zero
    }
    
    func keyPressed() -> UInt8? { (0..<UInt8(Constants.keys.count)).first { isKeyPressed($0) } }
}

// MARK: - CHIP8Delegate
extension MainApp: CHIP8Delegate {
    public func chip8(_ chip8: CHIP8, isPressingKey key: UInt8) -> Bool { isKeyPressed(key) }
    public func chip8(_ chip8: CHIP8, pauseAudio pause: Bool) { SDL_PauseAudio(pause ? 1 : .zero)  }
}
