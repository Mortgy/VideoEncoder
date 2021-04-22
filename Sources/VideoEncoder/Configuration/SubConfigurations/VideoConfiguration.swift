//
//  VideoConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/14/21.
//

import Foundation
import AVFoundation
import AVFoundation.AVVideoSettings

public struct VideoConfiguration {
    public var videoInputSetting: [String: Any]?
    public var videoOutputSetting: VideoOutputSettings
    public var videoComposition: VideoComposition
    
    public init(videoInputSetting: [String: Any]?, videoOutputSetting: VideoOutputSettings, videoComposition: VideoComposition) {
        self.videoInputSetting = videoInputSetting
        self.videoOutputSetting = videoOutputSetting
        self.videoComposition = videoComposition
    }
}

public struct VideoOutputSettings {
    
    public let portraitSize: CGSize
    public let landscapeSize: CGSize
    public let compressionSettings: CompressionSettings
    public let videoTrack: AVAssetTrack
    
    public init(portraitSize: CGSize = CGSize(width: 720, height: 1280), landscapeSize: CGSize = CGSize(width: 1280, height: 720), compressionSettings: CompressionSettings = CompressionSettings(), videoTrack: AVAssetTrack) {
        self.portraitSize = portraitSize
        self.landscapeSize = landscapeSize
        self.compressionSettings = compressionSettings
        self.videoTrack = videoTrack
    }
    
    public func outputConfiguration() -> [String: Any] {
        return videoSettings(size: sizeForVideoOrientation(), compression: compressionSettings.settings())
    }
    
    public func sizeForVideoOrientation() -> CGSize {
        let realVideoSize = VideoConfigurationHelper().naturaledSize(videoTrack: videoTrack)
        if realVideoSize.height > realVideoSize.width {
            return portraitSize
        }
        
        return landscapeSize
    }
    
    private func videoSettings(size: CGSize, compression: [String: Any]) -> [String: Any] {
        var settings: [String : Any] = [
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        
        settings[AVVideoCompressionPropertiesKey] = compression
        
        if #available(iOS 11.0, *) {
            settings[AVVideoCodecKey] = AVVideoCodecType.h264
        } else {
            settings[AVVideoCodecKey] = AVVideoCodecH264
        }
        
        return settings
    }
    
}

public struct CompressionSettings {
    
    let encoding: AVVideoCodecType
    let framePerSecond: Float
    let maxKeyframePerSecond: Int
    let bitRate: Int
    
    public init(encoding: AVVideoCodecType = .h264, framePerSecond: Float = 30, maxKeyframePerSecond: Int = 1, bitRate: Int = 2000000) {
        self.encoding = encoding
        self.framePerSecond = framePerSecond
        self.maxKeyframePerSecond = maxKeyframePerSecond
        self.bitRate = bitRate
    }
    
    func settings () -> [String: Any] {
        [
            AVVideoAverageNonDroppableFrameRateKey: framePerSecond,
            AVVideoAverageBitRateKey: bitRate,
            AVVideoMaxKeyFrameIntervalKey: maxKeyframePerSecond,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
        ]
    }
}

public struct VideoComposition {
    
    var videoOutputSettings: VideoOutputSettings
    var videoTrack: AVAssetTrack
    var customVideoComposition: AVMutableVideoComposition
    var hasCIFilter = false
    
    public init(videoOutputSettings: VideoOutputSettings, videoTrack: AVAssetTrack, customVideoComposition: AVMutableVideoComposition) {
        self.videoOutputSettings = videoOutputSettings
        self.videoTrack = videoTrack
        self.customVideoComposition = customVideoComposition
    }
    
    func composition() -> AVVideoComposition? {
        let videoSize = VideoConfigurationHelper().naturaledSize(videoTrack: videoTrack)
        let targetSize = videoOutputSettings.sizeForVideoOrientation()
        let transform = VideoConfigurationHelper().videoTransformation(videoTrack: videoTrack, naturalSize: videoSize, targetSize: targetSize)
        
        return buildComposition(with: videoTrack, customVideoComposition: customVideoComposition, usingCIFilter: hasCIFilter, fps: videoOutputSettings.compressionSettings.framePerSecond, videoSize: videoSize, transform: transform)
    }
    
    public mutating func usingCIFilter(hasCIFilter: Bool) {
        self.hasCIFilter = hasCIFilter
    }
    
    public mutating func updateCustomVideoComposition(customVideoComposition: AVMutableVideoComposition) {
        self.customVideoComposition = customVideoComposition
    }
    
    public func buildComposition(with videoTrack: AVAssetTrack, customVideoComposition: AVMutableVideoComposition, usingCIFilter: Bool, fps: Float, videoSize: CGSize, transform: CGAffineTransform) -> AVVideoComposition {
        let videoComposition = customVideoComposition
        
        let trackFrameRate = fps
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(trackFrameRate))
        
        videoComposition.renderSize = videoSize
        
        if usingCIFilter == false {
            let passThroughInstruction = AVMutableVideoCompositionInstruction()
            passThroughInstruction.timeRange = videoTrack.timeRange
            let passThroughLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            passThroughLayer.setTransform(transform, at: .zero)
            passThroughInstruction.layerInstructions = [passThroughLayer]
            videoComposition.instructions = [passThroughInstruction]
        }
        
        return videoComposition
    }
}

fileprivate struct VideoConfigurationHelper {
    
    func naturaledSize (videoTrack: AVAssetTrack) -> CGSize {
        var naturalSize = videoTrack.naturalSize
        
        let transform = videoTrack.preferredTransform
        let angle = atan2(transform.b, transform.a)
        let videoAngleInDegree = angle * 180 / CGFloat.pi
        
        if videoAngleInDegree == 90 || videoAngleInDegree == -90 {
            let width = videoTrack.naturalSize.width
            naturalSize.width = naturalSize.height
            naturalSize.height = width
        }
        
        return naturalSize
    }
    
    func videoTransformation(videoTrack: AVAssetTrack, naturalSize: CGSize, targetSize: CGSize) -> CGAffineTransform {
        var transform = videoTrack.preferredTransform
        
        if naturalSize.width > 0 && naturalSize.height > 0 {
            let xratio = targetSize.width / naturalSize.width
            let yratio = targetSize.height / naturalSize.height
            let ratio = min(xratio, yratio)
            let postWidth = naturalSize.width * ratio
            let postHeight = naturalSize.height * ratio
            let transx = (targetSize.width - postWidth) * 0.5
            let transy = (targetSize.height - postHeight) * 0.5
            var matrix = CGAffineTransform(translationX: transx / xratio, y: transy / yratio)
            matrix = matrix.scaledBy(x: ratio / xratio, y: ratio / yratio)
            transform = transform.concatenating(matrix)
        }
        
        return transform
    }
}
