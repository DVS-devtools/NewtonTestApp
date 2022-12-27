//
//  AppDelegate.swift
//  NewtonTestApp TV
//
//  Created by Jonny Cau on 24/02/21.
//  Copyright © 2021 d-MobileLab. All rights reserved.
//

import UIKit
import Newton

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        do {
            let _ = try Newton.getSharedInstanceWithConfig(conf: "<sec_ret>", customData: NWSimpleObject(fromDictionary: ["aKey": "aValue"]))
        } catch {
            print("Newton initialization failed with error \(error)")
            return false
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EntryPoint") as? Orchestrator
        viewController!.launchOptions = launchOptions
        self.window!.rootViewController = viewController
        self.window!.makeKeyAndVisible()
        return true
    }

}

