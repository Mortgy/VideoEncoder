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
        return videoSettings(w: sizeForVideoOrientation().width, h: sizeForVideoOrientation().height, compression: compressionSettings.settings())
    }
    
    public func sizeForVideoOrientation() -> CGSize {
        if videoTrack.naturalSize.height > videoTrack.naturalSize.width {
            return portraitSize
        }
        
        return landscapeSize
    }
    
    private func videoSettings(w: CGFloat, h: CGFloat, compression: [String: Any]) -> [String: Any] {
        var settings: [String : Any] = [
            AVVideoWidthKey: w,
            AVVideoHeightKey: h
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
    let maximumDuration: Double
    let framePerSecond: Float
    let maxKeyframePerSecond: Int
    let bitRate: Int
    
    public init(encoding: AVVideoCodecType = .h264, framePerSecond: Float = 24, maxKeyframePerSecond: Int = 1, bitRate: Int = 1000000, maximumDuration: Double = -1) {
        self.encoding = encoding
        self.framePerSecond = framePerSecond
        self.maxKeyframePerSecond = maxKeyframePerSecond
        self.bitRate = bitRate
        self.maximumDuration = maximumDuration
        
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
    
    public init(videoOutputSettings: VideoOutputSettings, videoTrack: AVAssetTrack) {
        self.videoOutputSettings = videoOutputSettings
        self.videoTrack = videoTrack
    }
    
    func composition() -> AVVideoComposition? {
        let videoSize = naturaledSize(videoTrack: videoTrack)
        let transform = videoTransformation(videoTrack: videoTrack, naturalSize: videoSize, targetSize: CGSize(width: videoOutputSettings.sizeForVideoOrientation().width, height: videoOutputSettings.sizeForVideoOrientation().height))
        
        return buildComposition(with: videoTrack, fps: videoOutputSettings.compressionSettings.framePerSecond, videoSize: videoSize, transform: transform)
    }
    
    func buildComposition(with videoTrack: AVAssetTrack, fps: Float, videoSize: CGSize, transform: CGAffineTransform) -> AVVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        
        let trackFrameRate = fps
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(trackFrameRate))
        
        videoComposition.renderSize = videoSize
        
        let passThroughInstruction = AVMutableVideoCompositionInstruction()
        passThroughInstruction.timeRange = videoTrack.timeRange
        let passThroughLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        passThroughLayer.setTransform(transform, at: .zero)
        passThroughInstruction.layerInstructions = [passThroughLayer]
        videoComposition.instructions = [passThroughInstruction]
        
        return videoComposition
    }
    
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
