//
//  MediaPicker.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import UIKit

class MediaPicker {
    private let pickerController: UIImagePickerController
    private weak var viewModelDelegate: VideoPickerViewModelDelegate?
    
    init() {
        pickerController = UIImagePickerController()
        pickerController.mediaTypes = ["public.movie"]
    }
    
    func setPickerDelegate(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        pickerController.delegate = delegate
    }
    
    func setPresenter(presenter: VideoPickerViewModelDelegate) {
        viewModelDelegate = presenter
    }
}

// MARK: - Picker Methods
extension MediaPicker {
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            pickerController.sourceType = type
            self.viewModelDelegate?.viewModelPresent(viewController: pickerController)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        viewModelDelegate?.viewModelPresent(viewController: alertController)
    }
}
