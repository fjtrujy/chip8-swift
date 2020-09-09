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

private var tonePos: Float = .zero
private var toneInc: Float = 2 * .pi * 1000 / Float(Constants.frequency)

struct AudioScpec {
    var spec = SDL_AudioSpec(freq: Constants.frequency,
                             format: SDL_AudioFormat(AUDIO_U8),
                             channels: 1,
                             silence: .zero,
                             samples: Constants.samples,
                             padding: .zero,
                             size: .zero,
                             callback: { (_, stream, len) in
                                (0..<len).forEach {
                                    stream?[Int($0)] = Uint8(sinf(tonePos) + Constants.audioCorrection)
                                    tonePos += toneInc
                                }
    },
                             userdata: nil)
}
