//
//  AudioConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/14/21.
//

import Foundation
import AVFoundation

struct AudioConfiguration {
    var audioInputSetting: [String: Any]?
    var audioOutputSetting: AudioOutputSettings?
    var audioMix: AVAudioMix?
    var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithm?
    
    init(audioOutputSetting: AudioOutputSettings = AudioOutputSettings()) {
        self.audioOutputSetting = audioOutputSetting
    }
    
}

struct AudioOutputSettings {
    let encoding: AudioFormatID
    let bitRate: Int
    let sampleRate: Int
    let numberOfChannels: Int
    
    init(encoding: AudioFormatID = kAudioFormatMPEG4AAC, bitRate: Int = 64000, sampleRate: Int = 44100, numberOfChannels: Int = 2) {
        self.encoding = encoding
        self.bitRate = bitRate
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
    }
    
    func outputSettings() -> [String: Any] {
        var stereoChannelLayout = AudioChannelLayout()
        memset(&stereoChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
        stereoChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
        
        let channelLayoutAsData = Data(bytes: &stereoChannelLayout, count: MemoryLayout<AudioChannelLayout>.size)
        let compressionAudioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: bitRate,
            AVSampleRateKey: sampleRate,
            AVChannelLayoutKey: channelLayoutAsData,
            AVNumberOfChannelsKey: numberOfChannels
        ]
        
        return compressionAudioSettings
    }
}
