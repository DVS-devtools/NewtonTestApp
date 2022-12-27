//
//  FromUser2.0To3.0.swift
//  NewtonTestApp
//
//  Created by Matteo Burgassi on 09/12/2020.
//  Copyright © 2020 d-MobileLab. All rights reserved.
//

import Foundation
import UIKit
import Newton

class From20To30Controller: UIViewController {

    @IBOutlet weak var dadanetUser: UITextView!
    @IBOutlet weak var infoUtente: UITextView!
    
    @IBAction func LoginTapped(_ sender: Any) {
        guard let dadanetUser = dadanetUser.text, let infoUtente = infoUtente.text else {
            return
        }
        do {
                     let builder = try Newton.getSharedInstance()
                         .getLoginBuilder()
                        .setDadanetUser(dadanetUser: dadanetUser)
                         .setInfoUtente(infoUtente: infoUtente)
        
        
            let flow = try builder.getUO2CredentialsLoginFlow()
            flow.startLoginFlow()
            self.navigationController?.popViewController(animated: true)
        }
        catch {
            print("Error: \(error)")
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
