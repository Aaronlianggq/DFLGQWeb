//
//  AppDelegate.swift
//  DFSDKApp
//
//  Created by qianduan-lianggq on 2023/1/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let root = ViewController()
        let rootNavigatePage = UINavigationController(rootViewController: root)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.rootViewController = rootNavigatePage
        self.window?.makeKeyAndVisible()
        return true
    }

}

