//
//  AppDelegate.swift
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 11/1/19.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .black
        window.rootViewController = rootController()
        self.window = window
        self.window?.makeKeyAndVisible()

        return true
    }

    func rootController() -> UIViewController {
        let controller = AlertCampaignListViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
}
