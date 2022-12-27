//
//  InAppPurchaseViewController.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 21/11/2017.
//  Copyright © 2017 d-MobileLab. All rights reserved.
//

import UIKit
import StoreKit
import Newton

protocol InAppPurchaseDelegate {
    func reloadData()
}

#if os(iOS)

class InAppPurchaseiOS: InAppPurchase, UIPickerViewDelegate, UIPickerViewDataSource, InAppPurchaseDelegate{
    @IBOutlet weak var productPicker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.products.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.products[row].localizedTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedProduct = self.products[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self

        productPicker.delegate = self
        productPicker.dataSource = self
    }
    
    func reloadData() {
        self.productPicker.reloadAllComponents()
    }
    
}
#else

class InAppPurchasetvOS: InAppPurchase, UITableViewDelegate, UITableViewDataSource, InAppPurchaseDelegate {
    
    @IBOutlet weak var productTableView: UITableView!
    
    func numberOfComponents(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedProduct = self.products[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if( !(cell != nil))
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        cell!.textLabel?.text = self.products[indexPath.row].localizedTitle

        return cell!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
        productTableView.delegate = self
        productTableView.dataSource = self
    }
    
    func reloadData() {
        self.productTableView.reloadData()
    }
    
}
#endif

class InAppPurchase: UIViewController, UITextFieldDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var debugLog: UITextView!
    
    var delegate:InAppPurchaseDelegate?
    
    let productIds: Set = ["test_subscription_001", "test_subscription_002"]
    var products =  [SKProduct]()
    var selectedProduct: SKProduct?
    
    var manager: NWPaymentManager?
    
    var offers = [String: String]()
    
    override func viewDidLoad() {
 
        self.debugLog.log("", overwrite: true)
        do {
            if self.manager == nil {
                self.manager = try Newton.getSharedInstance().getPaymentManager()
            }
        } catch {
            debugLog.log("Error in retrieving Payment Manager \(String(describing: error))")
        }
        let productsRequest = SKProductsRequest(productIdentifiers: self.productIds)
        productsRequest.delegate = self
        productsRequest.start()
        SKPaymentQueue.default().add(self)
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        debugLog.log("Found \(self.products.count) products:")
        for product in self.products {
            debugLog.log(product: product)
        }
        delegate?.reloadData()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            debugLog.log("Processing transaction \(String(describing: transaction.transactionIdentifier))")
            debugLog.log(payment: transaction.payment)
            var finish = false
            switch transaction.transactionState {
            case .purchasing:
                debugLog.log("Transaction in purchasing state")
            case .deferred:
                debugLog.log("Transaction in deferred state")
            case .failed:
                debugLog.log("Transaction failed!!!")
                finish = true
            case .purchased:
                debugLog.log("Transaction purchased!!")
                finish = true
            case .restored:
                debugLog.log("Transaction restored!!")
                finish = true
            @unknown default:
                debugLog.log("Transaction \(transaction.transactionState)")
                finish = true
            }
            if finish {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        debugLog.log("Error in restoring purchase \(String(describing: error))")
    }
    @IBAction func restorePurchaseButtonPressed(_ sender: Any) {
        guard SKPaymentQueue.canMakePayments() else {
            debugLog.log("In app purchases are disabled for this device")
            return
        }
        guard let product = self.selectedProduct else {
            debugLog.log("There are no products to buy. Fetch it first")
            return
        }
        guard let manager = self.manager else {
            debugLog.log("Error in retrieving Payment Manager")
            return
        }
        //Asking for an Offer
        let nativeItemId = product.productIdentifier
        manager.getOfferFor(nativeItem: nativeItemId) { (error, offerId) in
            guard error == nil else {
                if case NWError.NewtonError(let code, _, _, let reason) = error!, code == NewtonErrorCodes.ITEM_ALREADY_PAID {
                    self.debugLog.log("Item is already paid! \(String(describing: reason))")
                } else {
                    self.debugLog.log("Error in retrieving Offer \(String(describing: error!))")
                }
                return
            }
            //Creating a Restore request
            let restoreRequest = SKReceiptRefreshRequest()
            restoreRequest.delegate = self
            restoreRequest.start()
            self.offers[nativeItemId] = offerId!
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        guard SKPaymentQueue.canMakePayments() else {
            debugLog.log("In app purchases are disabled for this device")
            return
        }
        guard let product = self.selectedProduct else {
            debugLog.log("There are no products to buy. Fetch it first")
            return
        }
        guard let manager = self.manager else {
            debugLog.log("Error in retrieving Payment Manager")
            return
        }
        //Asking for an Offer
        let nativeItemId = product.productIdentifier
        manager.getOfferFor(nativeItem: nativeItemId) { (error, offerId) in
            guard error == nil else {
                if case NWError.NewtonError(let code, _, _, let reason) = error!, code == NewtonErrorCodes.ITEM_ALREADY_PAID {
                    self.debugLog.log("Item is already paid! \(String(describing: reason))")
                } else {
                    self.debugLog.log("Error in retrieving Offer \(String(describing: error!))")
                }
                return
            }
            //Creating a Payment request
            let payment = SKMutablePayment(product: product)
            payment.quantity = 1
            payment.applicationUsername = offerId!
            SKPaymentQueue.default().add(payment)
            self.offers[nativeItemId] = offerId!
        }
    }
    @IBAction func paymentLoginButtonPressed(_ sender: Any) {
        guard let product = self.selectedProduct else {
            debugLog.log("There are no products to buy. Fetch it first")
            return
        }
        if let offerId = self.offers[product.productIdentifier] {
            do {
                let flow = try Newton.getSharedInstance()
                    .getLoginBuilder()
                    .setOfferId(offerId: offerId)
                    .setOnFlowCompleteCallback() { (error) in
                        self.debugLog.log("Login flow has completed \(String(describing: error))")
                    }
                    .getPaymentReceiptLoginFlow()
                self.debugLog.log("Got flow \(flow)")
                flow.startLoginFlow()
            } catch {
                debugLog.log("Error in Payment Receipt Login Flow \(String(describing: error))")
            }
        } else {
            debugLog.log("There are no offers bought, please buy them first")
            return
        }
    }
    @IBAction func AddPaymentButtonPressed(_ sender: Any) {
        guard let product = self.selectedProduct, self.offers.count > 0  else {
            debugLog.log("There are no products or offers. Fetch it and buy it first")
            return
        }
        guard let paymentManager = self.manager else {
            debugLog.log("Error in retrieving manager")
            return
        }
        let nativeItemId = product.productIdentifier
        if let offerId = self.offers[nativeItemId] {
            paymentManager.addPayment(withOffer: offerId) { (error) in
                self.debugLog.log("Payment add: \(error != nil ? String(describing: error) : "OK")")
            }
        } else {
            debugLog.log("Error in retrieving offer")
            return
        }
    }
    
    @IBAction func receiptButtonPressed(_ sender: Any) {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           let receipt = try? Data(contentsOf: receiptURL, options: []) {
            debugLog.log("a Receipt has been found \(ByteCountFormatter.string(fromByteCount: Int64(receipt.count), countStyle: .file))")
            debugLog.log("\(String(data: receipt.base64EncodedData(), encoding: .utf8) ?? "N/A")")
        } else {
            debugLog.log("Unable to retrieve application receipt")
        }
    }
}
