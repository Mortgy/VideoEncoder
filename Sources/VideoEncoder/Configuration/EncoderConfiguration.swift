//
//  EncoderConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import AVFoundation

public struct EncoderConfiguration {
    
    public let audioConfiguration: AudioConfiguration
    public var videoConfiguration: VideoConfiguration
    public let exportConfiguration: ExportConfiguration

    public init(audioConfiguration: AudioConfiguration, videoConfiguration: VideoConfiguration, exportConfiguration: ExportConfiguration) {
        self.audioConfiguration = audioConfiguration
        self.videoConfiguration = videoConfiguration
        self.exportConfiguration = exportConfiguration
    }
}

public func defaultEncoderConfiguration(videoTrack: AVAssetTrack) -> EncoderConfiguration {

    let videoOutputSettings = VideoOutputSettings(videoTrack: videoTrack)
    let composition = VideoComposition(videoOutputSettings: videoOutputSettings, videoTrack: videoTrack, customVideoComposition: AVMutableVideoComposition())
    
    let videoConfig = VideoConfiguration(videoInputSetting: [String: Any](), videoOutputSetting: videoOutputSettings, videoComposition: composition)
    let audioConfig = AudioConfiguration()
    let exportConfig = ExportConfiguration()
    
    return EncoderConfiguration(audioConfiguration: audioConfig, videoConfiguration: videoConfig, exportConfiguration: exportConfig)
}
