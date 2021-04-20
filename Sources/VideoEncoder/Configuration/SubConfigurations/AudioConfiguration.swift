//
//  AudioConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/14/21.
//

import Foundation
import AVFoundation

public struct AudioConfiguration {
    public var audioInputSetting: [String: Any]?
    public var audioOutputSetting: AudioOutputSettings?
    public var audioMix: AVAudioMix?
    public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithm?
    
    public init(audioOutputSetting: AudioOutputSettings = AudioOutputSettings()) {
        self.audioOutputSetting = audioOutputSetting
    }
    
}

public struct AudioOutputSettings {
    public let encoding: AudioFormatID
    public let bitRate: Int
    public let sampleRate: Int
    public let numberOfChannels: Int
    
    public init(encoding: AudioFormatID = kAudioFormatMPEG4AAC, bitRate: Int = 64000, sampleRate: Int = 44100, numberOfChannels: Int = 2) {
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
