//
//  Main.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 27/01/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//

import UIKit
import Newton

class Main: UIViewController {
    @IBOutlet weak var textLog: UITextView!
    
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    fileprivate var flushNotification = NWNotification.AnalyticEventsFlushed

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textLog.log("Using Newton library version:\n\(Newton.versionString)")
        do {
            let envStr = try Newton.getSharedInstance().environmentString
            self.textLog.log("Environment: \(envStr)")
            let userToken = try! Newton.getSharedInstance().getUserToken()
            self.textLog.log("User Token: \(userToken)")
            let isLogged = try Newton.getSharedInstance().isUserLogged()
            self.textLog.log("User is Logged: \(isLogged)")
        } catch {
            self.textLog.log("Error in User Module \(error)")
        }
        self.flushNotification.addNamedObserver(name: "mainFlushObserver", senderObject: nil) { error, notification in
            if let error = error {
                self.textLog.log("Flush Notification Error: \(error)")
            } else if let userInfo = notification.userInfo {
                self.textLog.log("Flush Notification: \(userInfo)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if os(iOS)
        if let launchOptions = self.launchOptions,
            let navController = self.navigationController,
            let storyboard = self.storyboard,
            let viewController = storyboard.instantiateViewController(withIdentifier: "PushMain") as? PushMain {
                viewController.launchOptions = launchOptions
                navController.pushViewController(viewController, animated: true)
        }
        #endif
    }
    
    @IBAction func showDistributionGroupAlert(_ sender: Any) {
        let alert = UIAlertController(title: "type the distribution group to set", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "distribution group"
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let distributionGroup = alert.textFields?.first?.text {
                try! Newton.getSharedInstance().setDistributionGroup(distributionGroup: distributionGroup)
                self.textLog.log("distribution group set: \(distributionGroup)")
            }
        }))

        self.present(alert, animated: true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.flushNotification.clearObserver(name: "mainFlushObserver")
    }
}
