//
//  MFP.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 17/04/2018.
//  Copyright © 2018 d-MobileLab. All rights reserved.
//

import UIKit
import Newton

class MFP: UIViewController {

    @IBOutlet weak var debugLog: UITextView!
    @IBOutlet weak var newtonPonyText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.debugLog.log("", overwrite: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MFPRecognitionButtonPressed(_ sender: Any) {
        guard let newtonPony = self.newtonPonyText.text else {
            self.debugLog.log("A JSON String must be input")
            return
        }
        do {
            _ = try Newton.getSharedInstance()
                .getLoginBuilder()
                .setPony(pony: newtonPony)
                .setCustomData(cData: NWSimpleObject(fromDictionary: ["foo": "bar"])!)
                .setOnFlowCompleteCallback(callback: { (error) in
                    if let error = error {
                        self.debugLog.log("Flow completed with Error: \(String(describing: error))")
                    } else {
                        self.debugLog.log("Flow completed with Success")
                    }
                })
                .getMFPLoginFlow()
                .startLoginFlow()
        } catch {
            self.debugLog.log(String(describing: error))
        }
    }
}
