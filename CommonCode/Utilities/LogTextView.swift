//
//  LogTextView.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 27/01/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//

import UIKit
import StoreKit

extension UITextView {
    func log(_ log:String, overwrite: Bool = false) {
        debugPrint(log)
        DispatchQueue.main.async {
            if overwrite {
                self.text = "\(log)\n"
            } else {
                self.text = self.text + "\n\(log)\n"
            }
            let range = NSMakeRange(self.text.count - 10, 10)
            self.scrollRangeToVisible(range)
        }
    }
    
    func log(product: SKProduct) {
        let line = "Product identifier:\(product.productIdentifier) title:\(product.localizedTitle) description:\(product.localizedDescription) price:\(product.price)"
        self.log(line)
    }
    
    func log(payment: SKPayment) {
        let line = "Payment productIdentifier:\(payment.productIdentifier) quantity:\(payment.quantity) applicationUsername:\(String(describing: payment.applicationUsername))"
        self.log(line)
    }
}
