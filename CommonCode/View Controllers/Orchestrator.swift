//
//  Orchestrator.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 17/02/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//
/*
if let storyboard = self.storyboard,
let detailViewController = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController,
let navController = self.navigationController {
let selectedModel = self.tests[indexPath.row]
detailViewController.model = selectedModel

navController.pushViewController(detailViewController, animated: true)
}
*/
import UIKit
import StoreKit

class Orchestrator: UINavigationController {

    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    override func viewDidLoad() {
        //Set InAppPurchase as the Transaction observer
        if let storyboard = self.storyboard,
            let viewController = storyboard.instantiateViewController(withIdentifier: "InAppView") as? Main {
            SKPaymentQueue.default().add(viewController as! SKPaymentTransactionObserver)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Push Main view
        super.viewWillAppear(animated)
        if let storyboard = self.storyboard,
            let viewController = storyboard.instantiateViewController(withIdentifier: "MainView") as? Main {
                viewController.launchOptions = self.launchOptions
                self.pushViewController(viewController, animated: true)
        }
    }
}
