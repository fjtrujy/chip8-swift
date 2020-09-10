//
//  Audio.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 09/09/2020.
//

import Foundation
import SDL2

private enum Constants {
    static let frequency: Int32 = 44100
    static let samples: UInt16 = 4096
    static let audioCorrection: Float = 127
    static var userData = Audio.UserData()
}

struct Audio {
    fileprivate struct UserData {
        var tonePos: Float = .zero
        var toneInc: Float = 2 * .pi * 1000 / Float(Constants.frequency)
    }

    private var spec: SDL_AudioSpec
    private var dev: SDL_AudioDeviceID
    
    init() {
        let block: SDL_AudioCallback = { (userData, stream, len) in
            guard var userData = userData?.assumingMemoryBound(to: UserData.self).move()
                else { return }
            (0..<len).forEach {
                stream?[Int($0)] = Uint8(sinf(userData.tonePos) + Constants.audioCorrection)
                userData.tonePos += userData.toneInc
            }
        }
        
        var spec = SDL_AudioSpec(freq: Constants.frequency,
                                 format: SDL_AudioFormat(AUDIO_U8),
                                 channels: 1,
                                 silence: .min,
                                 samples: Constants.samples,
                                 padding: .min,
                                 size: .min,
                                 callback: block,
                                 userdata: &Constants.userData)
        
        let dev = SDL_OpenAudioDevice(nil, .zero, &spec, nil, SDL_AUDIO_ALLOW_FORMAT_CHANGE)
        
        self.spec = spec
        self.dev = dev
    }
    
    func pause(_ pause: Bool) { SDL_PauseAudioDevice(dev, pause ? 1 : .zero) }
    func close() { SDL_CloseAudioDevice(dev) }
}
