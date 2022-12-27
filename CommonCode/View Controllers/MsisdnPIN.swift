//
//  Msisdn.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 03/03/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//

import UIKit
import Newton

class MsisdnPIN: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var debugLog: UITextView!
    
    @IBOutlet weak var textNumber: UITextField!
    @IBOutlet weak var textPIN: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textNumber.resignFirstResponder()
        self.textPIN.resignFirstResponder()
        return true
    }
    
    @IBAction func verifyButtonPressed(_ sender: AnyObject) {
        guard let msisdn = self.textNumber.text,
            let pin = self.textPIN.text else {
            self.debugLog.log("Missing Credentials (MSISDN PIN)")
            return
        }
        do {
            try Newton.getSharedInstance()
                .getLoginBuilder()
                .setOnFlowCompleteCallback { error in
                    if let error = error {
                        self.debugLog.log("Error in MSISDN PIN Login Flow \(error)")
                    } else {
                        let userToken = try! Newton.getSharedInstance().getUserToken()
                        self.debugLog.log("MSISDN PIN Login Flow completed correctly. User is Logged with User Token: \(userToken)")
                    }
                }
                .setMSISDN(msisdn: msisdn)
                .setPIN(pin: pin)
                .getMSISDPINLoginFlow()
                .startLoginFlow()
        } catch {
            self.debugLog.log("Error in MSISDN PIN Login flow \(error)")
        }
        self.view.endEditing(true)
    }
    
    @IBAction func forgotButtonPressed(_ sender: AnyObject) {
        guard let msisdn = self.textNumber.text else {
            self.debugLog.log("Missing Credentials MSISDN")
            return
        }
        do {
            try Newton.getSharedInstance()
                .getLoginBuilder()
                .setOnFlowCompleteCallback { error in
                    if let error = error {
                        self.debugLog.log("Error in MSISDN PIN Forgot Flow \(error)")
                    } else {
                        self.debugLog.log("MSISDN PIN Forgot flow completed correctly")
                    }
                }
                .setMSISDN(msisdn: msisdn)
                .getMSISDPINLoginFlow()
                .startForgotFlow()
        } catch {
            self.debugLog.log("Error in MSISDN PIN Forgot flow \(error)")
        }
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        self.debugLog.log("", overwrite: true)
        do {
            let isLogged = try Newton.getSharedInstance().isUserLogged()
            if isLogged {
                let userToken = try! Newton.getSharedInstance().getUserToken()
                self.debugLog.log("WARNING: User is Logged with User Token: \(userToken). You must Log Out before start MSISDN")
            }            
        } catch {
            self.debugLog.log("Error in MSISDN PIN Flow \(error)")
        }
        self.textNumber.delegate = self
        self.textPIN.delegate = self
        super.viewDidLoad()
    }
}
