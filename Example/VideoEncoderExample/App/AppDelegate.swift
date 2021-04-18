//
//  AppDelegate.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/14/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = Coordinator()
        coordinator?.start()
        window?.rootViewController = coordinator?.rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

