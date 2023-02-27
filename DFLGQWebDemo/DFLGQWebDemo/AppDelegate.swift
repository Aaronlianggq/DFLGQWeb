//
//  AppDelegate.swift
//  DFLGQWebDemo
//
//  Created by qianduan-lianggq on 2023/2/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let root = ViewController()
        let rootNavigatePage = UINavigationController(rootViewController: root)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.rootViewController = rootNavigatePage
        self.window?.makeKeyAndVisible()
        return true
    }

    

}

