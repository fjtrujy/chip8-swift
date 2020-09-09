//
//  AudioScpec.swift
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
}

struct AudioUserData {
    var tonePos: Float = .zero
    var toneInc: Float = 2 * .pi * 1000 / Float(Constants.frequency)
}

var userData = AudioUserData()

struct AudioScpec {
    var spec = SDL_AudioSpec(freq: Constants.frequency,
                             format: SDL_AudioFormat(AUDIO_U8),
                             channels: 1,
                             silence: .min,
                             samples: Constants.samples,
                             padding: .min,
                             size: .min,
                             callback: { (userData, stream, len) in
                                guard var userData = userData?.assumingMemoryBound(to: AudioUserData.self).move()
                                    else { return }
                                (0..<len).forEach {
                                    stream?[Int($0)] = Uint8(sinf(userData.tonePos) + Constants.audioCorrection)
                                    userData.tonePos += userData.toneInc
                                }
    },
                             userdata: &userData)
}
