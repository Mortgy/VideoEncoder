//
//  VideoPickerViewController.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import UIKit

class VideoPickerViewController: UIViewController, Alert {

    let viewModel: VideoPickerViewModel
    
    init(viewModel: VideoPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        printDebug("Picker View Model Assigned")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func showVideoPickerAction(_ sender: UIButton) {
        viewModel.presentPicker(from: sender)
    }

}

// MARK: - View Model Delegate
extension VideoPickerViewController: VideoPickerViewModelDelegate {
    func viewModelPresent(viewController: UIViewController) {
        present(viewController, animated: true)
    }
}
