//
//  VideoEncoderViewController.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import UIKit

class EncoderViewController: UIViewController {

    var viewModel: EncoderViewModel
    @IBOutlet weak var progressView: UIProgressView!
    
    init(viewModel: EncoderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewModel.startEncoding()
    }
    
}

extension EncoderViewController: EncoderDelegate, Alert {

    func encodingProgressChanged(progress: Float) {
        progressView.progress = progress
    }
    
    func saveToLibrarySuccessful() {
        let action = UIAlertAction(title: Strings.ok.rawValue, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        showAlert(from: self, title: Strings.success.rawValue, message: Strings.compressionCompleted.rawValue, actions: [action])
    }
    
    func saveToLibraryFailed() {
        let action = UIAlertAction(title: Strings.ok.rawValue, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        showAlert(from: self, title: Strings.compressionFailed.rawValue, message: Strings.compressionFailedMessage.rawValue, actions: [action])
    }
}
