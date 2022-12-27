//
//  PushMain.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 27/01/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//

import UIKit
import Newton

class PushMain: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textLog: UITextView!
    @IBOutlet var fireTimerHorizontalSlider: UISlider!
    @IBOutlet var alertBodyTextField: UITextField!
    @IBOutlet weak var localPushSwitch: UISwitch!
    
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    override func viewDidLoad() {
        self.textLog.log("", overwrite: true)
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .setPushCallback { [weak self] push in
                    self?.textLog.log("A Push Notification has been handled. \(push.description)")
                }
                .setNotifyLaunchOptions(launchOptions: self.launchOptions)
            self.textLog.log("PushCallback set")
        } catch {
            self.textLog.log("Error in Push Module \(error)")
        }
        
        self.alertBodyTextField.delegate = self
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.alertBodyTextField.resignFirstResponder()
        return true
    }
    @IBAction func firePushButtonPressed(_ sender: AnyObject) {
        let seconds = TimeInterval(self.fireTimerHorizontalSlider.value)
        if localPushSwitch.isOn {
            //Auto Push
            print("Firing local notification with body:\(String(describing: self.alertBodyTextField.text)) in \(seconds) seconds...")
            do {
                try Newton.getSharedInstance()
                    .getPushManager()
                    .getPushBuilder()
                    .setDate(Date(timeIntervalSinceNow: seconds))
                    .setBody(self.alertBodyTextField.text!)
                    .setBadgeCounter(1)
                    .setCustomFields(NWSimpleObject(fromDictionary: ["badge number":"was \(0)", "waited seconds":seconds])!)
                    .scheduleLocalStandardPush()
            } catch {
                self.textLog.log("Error in AutoPush sending \(error)")
            }
        } else {
            //WARNING. Emulation of a Remote Push
            DispatchQueue.global().asyncAfter(deadline: .now() + seconds) { () -> Void in
                let userInfo: [AnyHashable: Any] = [
                    "aps": [
                        "alert": self.alertBodyTextField.text ?? "",
                        "badge": 2
                    ],
                    "push_id": UUID().uuidString,
                    "t": "N",
                    "custom": [
                        "keyA": "valueA",
                        "keyB": "valueB"
                    ]
                ]
                
                do {
                    try Newton.getSharedInstance()
                        .getPushManager()
                        .processRemoteNotification(userInfo: userInfo)
                } catch {
                    self.textLog.log("Error in Fake RemotePush sending \(error)")
                }
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        //NOTE: This should be made every time the application is launched. It's here only for demo purposes
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .registerDevice()
            self.textLog.log("Register device called")
        } catch {
            self.textLog.log("Error in Push Registration \(error)")
        }
    }
}
