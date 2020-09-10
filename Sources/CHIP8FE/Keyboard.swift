//
//  File.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 10/09/2020.
//

import Foundation
import SDL2

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

struct Keyboard {
    var keyPressed: UInt8? { (0..<UInt8(Constants.keys.count)).first { isKeyPressed($0) } }
    
    func isKeyPressed(_ key: UInt8) -> Bool {
        guard let sdlKeys = SDL_GetKeyboardState(nil) else { return false }
        return sdlKeys[Int(Constants.keys[Int(key)].rawValue)] != .zero
    }
}
