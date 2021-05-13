//
//  Alert.swift
//  GetirTodo
//
//  Created by Mortgy on 4/11/21.
//

import Foundation
import UIKit

protocol Alert {
    func showAlert(title: String, message: String, actions: [UIAlertAction]?)
}

extension Alert where Self: UIViewController{
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController  == nil else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions == nil {
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        
        actions?.forEach { action in
            alertController.addAction(action)
        }
        
        present(alertController, animated: true)
    }
}
