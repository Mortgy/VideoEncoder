//
//  EncoderConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import AVFoundation

public struct EncoderConfiguration {
    
    let audioConfiguration: AudioConfiguration
    let videoConfiguration: VideoConfiguration
    let exportConfiguration: ExportConfiguration

    init(audioConfiguration: AudioConfiguration, videoConfiguration: VideoConfiguration, exportConfiguration: ExportConfiguration) {
        self.audioConfiguration = audioConfiguration
        self.videoConfiguration = videoConfiguration
        self.exportConfiguration = exportConfiguration
    }
}

public func defaultEncoderConfiguration(videoTrack: AVAssetTrack) -> EncoderConfiguration {

    let videoOutputSettings = VideoOutputSettings(videoTrack: videoTrack)
    let composition = VideoComposition(videoOutputSettings: videoOutputSettings, videoTrack: videoTrack)
    
    let videoConfig = VideoConfiguration(videoInputSetting: [String: Any](), videoOutputSetting: videoOutputSettings, videoComposition: composition)
    let audioConfig = AudioConfiguration()
    let exportConfig = ExportConfiguration()
    
    return EncoderConfiguration(audioConfiguration: audioConfig, videoConfiguration: videoConfig, exportConfiguration: exportConfig)
}
