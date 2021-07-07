//
//  EncoderViewModel.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import AVFoundation
import Photos

protocol EncoderDelegate: AnyObject {
    func encodingProgressChanged(progress: Float)
    func saveToLibrarySuccessful()
    func saveToLibraryFailed()
}

class EncoderViewModel {
    fileprivate var encoderConfiguration: EncoderConfiguration
    fileprivate var exportSession: VideoEncoder!
    private(set) weak var coordinator: Coordinator!
    weak var delegate: EncoderDelegate?
    let model: EncoderModel
    
    init(coordinator: Coordinator, encoderConfiguration: EncoderConfiguration, model: EncoderModel) {
        self.coordinator = coordinator
        self.encoderConfiguration = encoderConfiguration
        self.model = model
    }
    
    func startEncoding() {
        exportSession = VideoEncoder(asset: model.videoAsset, encoderConfiguration: encoderConfiguration)
        
        exportSession.progressHandler = { [weak self] (progress) in
            DispatchQueue.main.async {
                self?.delegate?.encodingProgressChanged(progress: progress)
            }
        }
        
        exportSession.completionHandler = { [weak self] (error) in
            self?.saveOutputToLibrary(fileURL: (self?.encoderConfiguration.exportConfiguration.outputURL)!)
        }
        
        exportSession.export()
    }
}

// MARK: - Save file to photos
extension EncoderViewModel {
    func saveOutputToLibrary(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { [weak self] (saved, error) in
            DispatchQueue.main.async {
                if saved {
                    self?.delegate?.saveToLibrarySuccessful()
                } else {
                    self?.delegate?.saveToLibraryFailed()
                }
            }
        }
    }
}
