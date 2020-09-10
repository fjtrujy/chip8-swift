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
    static let frameDuration = 1000/60
}

public class Emulation {
    private let chip8: CHIP8
    private let video: Video
    private let audio: Audio
    private let keyboard: Keyboard

    public init(chip8: CHIP8 = CHIP8()) {
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)
        self.chip8 = chip8
        self.audio = Audio()
        self.video = Video()
        self.keyboard = Keyboard()
    }

    public func start(game: Data) {
        guard chip8.loadROM(data: game) else { return }
        chip8.delegate = self

        var event = SDL_Event()
        var mustQuit: Bool = false
        var lastTick: UInt32 = SDL_GetTicks()
        var cycles: UInt32 = SDL_GetTicks()
        
        while !mustQuit {
            while (SDL_PollEvent(&event) != .zero) {
                switch (event.type) {
                case SDL_QUIT.rawValue: mustQuit = true;
                default: break
               }
            }
            
            if (SDL_GetTicks() - cycles > 1) {
                if !chip8.isWaitingKey {
                    chip8.step()
                } else if let key = keyboard.keyPressed {
                    chip8.keyPressed(key: key)
                }
                cycles = SDL_GetTicks()
            }
            
            if (SDL_GetTicks() - lastTick > Constants.frameDuration) {
                chip8.decreaseTimers()
                
                video.render(screenContent: chip8.screenContent)
                lastTick = SDL_GetTicks()
            }
        }
        
        finishExecution()
    }
}

// MARK: - Private Methods
private extension Emulation {
    func finishExecution() {
        video.finish()
        audio.close()
        SDL_Quit()
    }
}

// MARK: - CHIP8Delegate
extension Emulation: CHIP8Delegate {
    public func chip8(_ chip8: CHIP8, isPressingKey key: UInt8) -> Bool { keyboard.isKeyPressed(key) }
    public func chip8(_ chip8: CHIP8, pauseAudio pause: Bool) { audio.pause(pause) }
}
