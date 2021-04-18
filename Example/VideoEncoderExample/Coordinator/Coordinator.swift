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
        let viewModel = VideoPickerViewModel(coordinator: self)
        rootViewController = VideoPickerViewController(viewModel: viewModel)
    }
    
    func openEncoder(with videoAssetURL: URL) {
        
        let videoAsset = AVAsset(url: videoAssetURL)
        if let videoTrack = videoAsset.tracks(withMediaType: .video).first {
            
            let encoderConfiguration = defaultEncoderConfiguration(videoTrack: videoTrack)
            let viewModel = EncoderViewModel(coordinator: self, encoderConfiguration: encoderConfiguration, videoAssetUrl: videoAssetURL)
            
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
}

