//
//  VideoPickerViewModel.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import UIKit
import AVFoundation

public protocol VideoPickerViewModelDelegate: class {
    func viewModelPresent(viewController: UIViewController)
}

open class VideoPickerViewModel: NSObject {
    
    weak var delegate: VideoPickerViewModelDelegate! {
        didSet {
            picker = MediaPicker(delegate: self, presenter: delegate!)
        }
    }
    
    private(set) weak var coordinator: Coordinator!
    private(set) var picker: MediaPicker?
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init()
    }
    
    func presentPicker(from: UIView) {
        picker?.present(from: from)
        printDebug("Media Picker Presented")
    }
}


extension VideoPickerViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if info[.mediaType] as! String == "public.movie" {
                if let url = info[.mediaURL] as? URL {
                    //coordinator
                    printDebug("Media Picked, Redirecting to Encoder")
                    self?.coordinator.openEncoder(with: url)
                }
            }
        }
    }
}
