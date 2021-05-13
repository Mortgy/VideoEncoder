//
//  VideoEncoder.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/16/21.
//

import Foundation
import AVFoundation
import Photos

public class VideoEncoder {
    
    private(set) var asset: AVAsset
    
    fileprivate var encoderConfiguration: EncoderConfiguration
    fileprivate var reader: AVAssetReader!
    fileprivate var videoOutput: AVAssetReaderVideoCompositionOutput?
    fileprivate var audioOutput: AVAssetReaderAudioMixOutput?
    fileprivate var writer: AVAssetWriter!
    fileprivate var videoInput: AVAssetWriterInput?
    fileprivate var audioInput: AVAssetWriterInput?
    fileprivate var inputQueue = DispatchQueue(label: "VideoEncoderQueue")
    fileprivate var videoCompleted = false
    fileprivate var audioCompleted = false
    
    private var lastVideoSamplePresentationTime: CMTime = .zero
    private var lastAudioSamplePresentationTime: CMTime = .zero
    
    public var progressHandler: ((Float) -> Void)?
    public var completionHandler: ((Error?) -> Void)?
    
    // MARK: - Exporting properties
    public var progress: Float = 0 {
        didSet {
            //considering video and audio progress
            progressHandler?(progress/2)
        }
    }
    public var videoProgress: Float = 0 {
        didSet {
            if audioInput != nil {
                progress = videoProgress + audioProgress
            } else {
                progress = videoProgress
            }
        }
    }
    public var audioProgress: Float = 0 {
        didSet {
            if videoInput != nil {
                progress = videoProgress + audioProgress
            } else {
                progress = audioProgress
            }
        }
    }
    
    public init(asset: AVAsset, encoderConfiguration: EncoderConfiguration) {
        self.asset = asset
        self.encoderConfiguration = encoderConfiguration
    }
    
    // MARK: - Main
    public func cancelExport() {
        if let writer = writer, let reader = reader {
            inputQueue.async {
                writer.cancelWriting()
                reader.cancelReading()
            }
        }
    }
    
    public func export() {
        cancelExport()
        reset()
        do {
            reader = try AVAssetReader(asset: asset)
            
            // Export Configuration
            writer = try AVAssetWriter(url: encoderConfiguration.exportConfiguration.outputURL, fileType: encoderConfiguration.exportConfiguration.fileType)
            writer.shouldOptimizeForNetworkUse = encoderConfiguration.exportConfiguration.shouldOptimizeForNetworkUse
            writer.metadata = encoderConfiguration.exportConfiguration.metadata
            
            // Maximum Video Duration
            let duration: CMTimeRange
            if let timeRange = encoderConfiguration.exportConfiguration.timeRange {
                duration = timeRange
            } else if encoderConfiguration.exportConfiguration.maximumDuration > 0 && asset.duration.seconds > encoderConfiguration.exportConfiguration.maximumDuration {
                let beginTime = CMTimeMakeWithSeconds(0, preferredTimescale: asset.duration.timescale)
                duration = CMTimeRangeMake(start: beginTime, duration: CMTimeMakeWithSeconds(encoderConfiguration.exportConfiguration.maximumDuration, preferredTimescale: asset.duration.timescale))
            } else {
                duration = CMTimeRangeMake(start: CMTime(value: 0, timescale: asset.duration.timescale), duration: asset.duration)
            }
            
            reader.timeRange = duration
            
            // Video output
            let videoTracks = asset.tracks(withMediaType: .video)
            if videoTracks.count > 0 {
                
                let videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
                videoOutput.alwaysCopiesSampleData = false
                videoOutput.videoComposition = encoderConfiguration.videoConfiguration.videoComposition.composition()
                
                guard reader.canAdd(videoOutput) else {
                    throw NSError(domain: "com.exportsession", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Can't add video output", comment: "")])
                }
                reader.add(videoOutput)
                self.videoOutput = videoOutput
                
                // Video input
                let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: encoderConfiguration.videoConfiguration.videoOutputSetting.outputConfiguration())
                videoInput.expectsMediaDataInRealTime = false
                guard writer.canAdd(videoInput) else {
                    throw NSError(domain: "com.exportsession", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Can't add video input", comment: "")])
                }
                writer.add(videoInput)
                self.videoInput = videoInput
            }
            
            // Audio output
            let audioTracks = asset.tracks(withMediaType: .audio)
            if audioTracks.count > 0 {
                
                let audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: encoderConfiguration.audioConfiguration.audioInputSetting)
                audioOutput.alwaysCopiesSampleData = false
                audioOutput.audioMix = encoderConfiguration.audioConfiguration.audioMix
                if let audioTimePitchAlgorithm = encoderConfiguration.audioConfiguration.audioTimePitchAlgorithm {
                    audioOutput.audioTimePitchAlgorithm = audioTimePitchAlgorithm
                }
                if reader.canAdd(audioOutput) {
                    reader.add(audioOutput)
                    self.audioOutput = audioOutput
                }
                
                if self.audioOutput != nil {
                    // Audio input
                    let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: encoderConfiguration.audioConfiguration.audioOutputSetting?.outputSettings())
                    audioInput.expectsMediaDataInRealTime = false
                    if writer.canAdd(audioInput) {
                        writer.add(audioInput)
                        self.audioInput = audioInput
                    }
                }
            }
            
            writer.startWriting()
            reader.startReading()
            writer.startSession(atSourceTime: duration.start)
            
            encodeVideoData()
            encodeAudioData()
        } catch {
            self.completionHandler?(error)
        }
    }
    
    fileprivate func encodeVideoData() {
        if let videoInput = videoInput {
            videoInput.requestMediaDataWhenReady(on: inputQueue, using: { [weak self] in
                guard let videoOutput = self?.videoOutput, let videoInput = self?.videoInput else { return }
                self?.encodeReadySamplesFrom(output: videoOutput, to: videoInput, completion: {
                    self?.videoCompleted = true
                    self?.tryFinish()
                })
            })
        } else {
            videoCompleted = true
            tryFinish()
        }
    }
    
    fileprivate func encodeAudioData() {
        if let audioInput = audioInput {
            audioInput.requestMediaDataWhenReady(on: inputQueue, using: { [weak self] in
                guard let audioOutput = self?.audioOutput, let audioInput = self?.audioInput else { return }
                self?.encodeReadySamplesFrom(output: audioOutput, to: audioInput, completion: {
                    self?.audioCompleted = true
                    self?.tryFinish()
                })
            })
        } else {
            audioCompleted = true
            tryFinish()
        }
    }
    
    fileprivate func encodeReadySamplesFrom(output: AVAssetReaderOutput, to input: AVAssetWriterInput, completion: @escaping () -> Void) {
        while input.isReadyForMoreMediaData {
            let complete = autoreleasepool(invoking: { [weak self] () -> Bool in
                if let sampleBuffer = output.copyNextSampleBuffer() {
                    guard self?.reader.status == .reading && self?.writer.status == .writing else {
                        return true
                    }
                    
                    guard input.append(sampleBuffer) else {
                        return true
                    }
                    
                    if let videoOutput = self?.videoOutput, videoOutput == output {
                        lastVideoSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        if (self?.asset.duration.seconds)! > 0 {
                            self?.videoProgress = Float(lastVideoSamplePresentationTime.seconds / (self?.asset.duration.seconds)!)
                        } else {
                            self?.videoProgress = 1
                        }
                    } else if let audioOutput = self?.audioOutput, audioOutput == output {
                        lastAudioSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        if (self?.asset.duration.seconds)! > 0 {
                            self?.audioProgress = Float(lastAudioSamplePresentationTime.seconds / (self?.asset.duration.seconds)!)
                        } else {
                            self?.audioProgress = 1
                        }
                    }
                } else {
                    input.markAsFinished()
                    return true
                }
                return false
            })
            if complete {
                completion()
                break
            }
        }
    }
    
    fileprivate func tryFinish() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if audioCompleted && videoCompleted {
            if reader.status == .cancelled || writer.status == .cancelled {
                finish()
            } else if writer.status == .failed {
                finish()
            } else if reader.status == .failed {
                writer.cancelWriting()
                finish()
            } else {
                writer.finishWriting { [weak self] in
                    self?.finish()
                }
            }
        }
    }
    
    fileprivate func finish() {
        if writer.status == .failed || reader.status == .failed {
            try? FileManager.default.removeItem(at: encoderConfiguration.exportConfiguration.outputURL)
        }
        let error = writer.error ?? reader.error
        completionHandler?(error)
    }
    
    fileprivate func reset() {
        videoCompleted = false
        
        videoProgress = 0
        audioProgress = 0
        progress = 0
        
        reader = nil
        writer = nil
        
        videoOutput = nil
        videoInput = nil
        audioInput = nil
    }
    
}
