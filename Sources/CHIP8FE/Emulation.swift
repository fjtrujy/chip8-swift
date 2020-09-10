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

public class Emulation {
    private let chip8: CHIP8
    private var video: Video
    private var audio: Audio

    public init(chip8: CHIP8 = CHIP8()) {
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)
        self.chip8 = chip8
        self.audio = Audio()
        self.video = Video()
    }

    public func start(game: Data) {
        guard chip8.loadROM(data: game) else { return }
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
                
                video.render(screenContent: chip8.screenContent)
                lastTick = SDL_GetTicks()
            }
        }
        
        finishExecution()
    }
}

private extension Emulation {
    func finishExecution() {
        video.finish()
        audio.close()
        SDL_Quit()
    }
    
    func isKeyPressed(_ key: UInt8) -> Bool {
        guard let sdlKeys = SDL_GetKeyboardState(nil) else { return false }
        return sdlKeys[Int(Constants.keys[Int(key)].rawValue)] != .zero
    }
    
    func keyPressed() -> UInt8? { (0..<UInt8(Constants.keys.count)).first { isKeyPressed($0) } }
}

// MARK: - CHIP8Delegate
extension Emulation: CHIP8Delegate {
    public func chip8(_ chip8: CHIP8, isPressingKey key: UInt8) -> Bool { isKeyPressed(key) }
    public func chip8(_ chip8: CHIP8, pauseAudio pause: Bool) { audio.pause(pause) }
}
