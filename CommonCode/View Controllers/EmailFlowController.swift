//
//  EmailFlowController.swift
//  NewtonTestApp
//
//  Created by Matteo Burgassi on 28/05/2019.
//  Copyright © 2019 d-MobileLab. All rights reserved.
//

import Foundation
import UIKit
import Newton

class EmailFlowController: UIViewController {
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var errorTextView: UITextView!
    
    @IBAction func addEmailIdentityTapped(_ sender: Any) {
        guard let email = emailTextView.text, emailTextView.text != "" else {
            self.setLogText("missing Email")
            return
        }
        guard let pwd = password.text, password.text != "" else {
            self.setLogText("missing password")
            return
        }
        do {
            let builder = try Newton.getSharedInstance()
                .getIdentityManager()
                .getIdentityBuilder()
                .setEmail(email: email)
                .setPassword(password: pwd)
                .setOnFlowCompleteCallback {error in
                    if let error = error {
                        self.setLogText("Add Email Flow completed with Error: \(error)")
                    } else {
                        self.setLogText("Add Email went well")
                    }
            }
            let addEmailFlow = try builder.getAddEmailIdentityFlow()
            addEmailFlow.startIdentityFlow()
        } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
            print("Newton not initialized: \(String(describing: reason))")
        } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
            print("Login builder Error: \(String(describing: reason))")
        } catch {
            self.setLogText("Unknown Error: \(error)")
            
        }
        
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextView.text, emailTextView.text != "" else {
            self.setLogText("missing Email")
            return
        }
        guard let pwd = password.text, password.text != "" else {
            self.setLogText("missing password")
            return
        }
        do {
            let builder = try Newton.getSharedInstance().getLoginBuilder()
            .setEmail(email: email)
            .setPassword(password: pwd)
                .setOnFlowCompleteCallback {error in
                    if let error = error {
                        self.setLogText("Login Flow completed with Error: \(error)")
                    } else {
                        self.setLogText("Login Flow went well")
                    }
            }
            let loginflow = try builder.getEmailLoginFlow()
            loginflow.startLoginFlow()
        } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
            print("Newton not initialized: \(String(describing: reason))")
        } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
            print("Login builder Error: \(String(describing: reason))")
         } catch {
             print("Unknown Error: \(error)")
            
 }
    }
        
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let email = emailTextView.text, emailTextView.text != "" else {
            self.setLogText("missing Email")
            return
        }
        guard let pwd = password.text, password.text != "" else {
            self.setLogText("missing password")
            return
        }
        do {
            let builder = try Newton.getSharedInstance().getLoginBuilder()
                .setEmail(email: email)
                .setPassword(password: pwd)
                .setOnFlowCompleteCallback {error in
                    if let error = error {
                        self.setLogText("Signup login Flow completed with Error: \(error)")
                    } else {
                        self.setLogText("Signup login Flow went well")
                    }
            }
            let loginflow = try builder.getEmailSignupFlow()
            loginflow.startLoginFlow()
        } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
            print("Newton not initialized: \(String(describing: reason))")
        } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
            print("Login builder Error: \(String(describing: reason))")
        } catch {
            print("Unknown Error: \(error)")
        }
    }
        
    @IBAction func resendButtonTapped(_ sender: Any) {
        guard let email = emailTextView.text, emailTextView.text != "" else {
            self.setLogText("missing Email")
            return
        }
        do {
            let builder = try Newton.getSharedInstance().getLoginBuilder()
                .setEmail(email: email)
                .setOnFlowCompleteCallback {error in
                    if let error = error {
                        self.setLogText("Email Resend Flow completed with Error: \(error)")
                    } else {
                        self.setLogText("Email Resend Signup login Flow went well")
                    }
            }
            let loginflow = try builder.getEmailResendFlow()
            loginflow.startLoginFlow()
        } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
            print("Newton not initialized: \(String(describing: reason))")
        } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
            print("Login builder Error: \(String(describing: reason))")
        } catch {
            print("Unknown Error: \(error)")
        }
    }
        
    @IBAction func forgotButtonTapped(_ sender: Any) {
        guard let email = emailTextView.text, emailTextView.text != "" else {
            self.setLogText("missing Email")
            return
        }
        do {
            let builder = try Newton.getSharedInstance().getLoginBuilder()
                .setEmail(email: email)
                .setOnFlowCompleteCallback { error in
                    if let error = error {
                        self.setLogText("Email Forgot Flow completed with Error: \(error)")
                    } else {
                        self.setLogText("Email Forgot Signup login Flow went well")
                    }
            }
            let loginflow = try builder.getEmailForgotFlow()
            loginflow.startLoginFlow()
        } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
            print("Newton not initialized: \(String(describing: reason))")
        } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
            print("Login builder Error: \(String(describing: reason))")
        } catch {
            print("Unknown Error: \(error)")
        }
    }
        
    override func viewDidLoad() {
        print("EmailFlowController loaded")
    }
    
    func setLogText(_ text: String){
        self.errorTextView.log(text)
    }
}
