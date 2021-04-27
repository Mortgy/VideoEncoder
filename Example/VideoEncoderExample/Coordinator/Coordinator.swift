//
//  Coordinator.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import UIKit
import AVFoundation

class Coordinator: NSObject {
    
    var rootViewController: UIViewController!
    
    func start() {
        printDebug("Coordinator Starting")
        let picker = MediaPicker()
        let model = VideoPickerModel(picker: picker)
        let viewModel = VideoPickerViewModel(coordinator: self, model: model)
        rootViewController = VideoPickerViewController(viewModel: viewModel)
    }
    
    func openEncoder(with videoAssetURL: URL) {
        
        let videoAsset = AVAsset(url: videoAssetURL)
        if let videoTrack = videoAsset.tracks(withMediaType: .video).first {
            
            let encoderConfiguration = defaultEncoderConfiguration(videoTrack: videoTrack)
            //enable to test using CIFilters
//            encoderConfiguration.videoConfiguration.videoComposition.usingCIFilter(hasCIFilter: true)
//            encoderConfiguration.videoConfiguration.videoComposition.updateCustomVideoComposition(customVideoComposition: applyFilter(videoAsset: videoAsset))
            let model = EncoderModel(videoAssetUrl: videoAssetURL)
            let viewModel = EncoderViewModel(coordinator: self, encoderConfiguration: encoderConfiguration, model: model)
            
            let encoderViewController = EncoderViewController(viewModel: viewModel)
            encoderViewController.modalPresentationStyle = .fullScreen
            encoderViewController.definesPresentationContext = true
            encoderViewController.modalTransitionStyle = .crossDissolve
            
            rootViewController.present(encoderViewController, animated: true) {
                printDebug("Encoder Controller Presented")
            }
        } else {
            if let rootVC = rootViewController as? (UIViewController & Alert) {
                rootVC.showAlert(from: rootVC, title: Strings.invalidVideo.rawValue, message: Strings.invalidVideoMessage.rawValue)
                printDebug("Invalid video track provided")
            }
        }
        
    }
    
    func present(viewController: UIViewController, from: UIViewController) {
        from.present(viewController, animated: true)
    }
    
    func applyFilter(videoAsset: AVAsset) -> AVMutableVideoComposition{
        return AVMutableVideoComposition(asset: videoAsset, applyingCIFiltersWithHandler: { request in
            let imageFilter = CIFilter(name: "CIPhotoEffectChrome")

            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            imageFilter!.setValue(source, forKey: kCIInputImageKey)
            
            // Crop the blurred output to the bounds of the original image
            let output = imageFilter?.outputImage!.cropped(to: request.sourceImage.extent)
            
            // Provide the filter output to the composition
            request.finish(with: output!, context: nil)
        })
    }
}

