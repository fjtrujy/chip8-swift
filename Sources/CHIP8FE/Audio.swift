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
    static let samples: UInt16 = 1024
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
        
        var spec = SDL_AudioSpec()
        spec.freq = Constants.frequency
        spec.format = SDL_AudioFormat(AUDIO_U8)
        spec.channels = 1
        spec.samples = Constants.samples
        spec.callback = block
        spec.userdata = withUnsafeMutablePointer(to: &Constants.userData) {UnsafeMutableRawPointer($0)}
        
        let dev = SDL_OpenAudioDevice(nil, .zero, &spec, nil, SDL_AUDIO_ALLOW_FORMAT_CHANGE)
        
        self.spec = spec
        self.dev = dev
    }
    
    func pause(_ pause: Bool) {
        let currentStatus = SDL_GetAudioDeviceStatus(dev)
        let desiredStatus = pause ? SDL_AUDIO_PAUSED : SDL_AUDIO_PLAYING
        guard currentStatus != desiredStatus else { return }
        SDL_PauseAudioDevice(dev, pause ? 1 : .zero) }
    func close() { SDL_CloseAudioDevice(dev) }
}
