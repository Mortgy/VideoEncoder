//
//  Alert.swift
//  GetirTodo
//
//  Created by Mortgy on 4/11/21.
//

import Foundation
import UIKit

protocol Alert {
    func showAlert(from: (UIViewController & Alert), title: String, message: String, actions: [UIAlertAction]?)
}

extension Alert where Self: UIViewController{
    func showAlert(from: (UIViewController & Alert), title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard from.presentedViewController  == nil else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions == nil {
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        
        actions?.forEach { action in
            alertController.addAction(action)
        }
        
        from.present(alertController, animated: true)
    }
}
