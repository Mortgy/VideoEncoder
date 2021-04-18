//
//  EncoderConfigurationTests.swift
//  VideoEncoderTests
//
//  Created by Mortgy on 4/16/21.
//

import XCTest
import AVFoundation
@testable import VideoEncoder

class EncoderConfigurationTests: XCTestCase {

    func test_EncoderConfiguration_defaultConfigurationsMatchRequirements() {
        // given
        let bundle = Bundle(for: EncoderConfigurationTests.self)
        let path = bundle.path(forResource: "Video", ofType: "MP4")
        let videoAsset = AVAsset(url: URL(string: path!)!)
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            XCTAssertNil(nil, "Video Track Not Found")
            return
        }
        
        // when
        let encoderConfiguration = defaultEncoderConfiguration(videoTrack: videoTrack)

        // then
        
        // Video Configurations
        // Output Configurations
        let outputConfig: VideoOutputSettings =  encoderConfiguration.videoConfiguration.videoOutputSetting
        
        XCTAssertEqual(outputConfig.width, 540)
        XCTAssertEqual(outputConfig.height, 960)
        
        // Compression Configurations
        let compressionConfig: CompressionSettings = outputConfig.compressionSettings
        
        XCTAssertEqual(compressionConfig.encoding, .h264)
        XCTAssertEqual(compressionConfig.framePerSecond, 24)
        XCTAssertEqual(compressionConfig.maximumDuration, 20)
        XCTAssertEqual(compressionConfig.maxKeyframePerSecond, 1)
        XCTAssertEqual(compressionConfig.bitRate, 1000000)
        
        // Composition Output
        XCTAssertNotNil(encoderConfiguration.videoConfiguration.videoComposition.composition())

        
        // Export Configuration
        let exportConfiguration = encoderConfiguration.exportConfiguration
        XCTAssertEqual(exportConfiguration.fileType, .mp4)
        XCTAssertEqual(exportConfiguration.shouldOptimizeForNetworkUse, false)
        XCTAssertEqual(exportConfiguration.metadata, [])

        
        // Audio Configuration
        let audioConfiguration = encoderConfiguration.audioConfiguration
        XCTAssertNotNil(audioConfiguration.audioOutputSetting)
        
        // Audio Output Configuration
        let audioOutput = audioConfiguration.audioOutputSetting
        XCTAssertEqual(audioOutput?.encoding, kAudioFormatMPEG4AAC)
        XCTAssertEqual(audioOutput?.bitRate, 64000)
        XCTAssertEqual(audioOutput?.sampleRate, 44100)
        XCTAssertEqual(audioOutput?.numberOfChannels, 2)
    }

}
