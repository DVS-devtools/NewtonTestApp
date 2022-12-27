//
//  MsisdnUR.swift
//  NewtonTestApp
//
//  Created by Alessandro Castrucci on 30/03/16.
//  Copyright © 2016 d-MobileLab. All rights reserved.
//

import UIKit

import WebKit
import Newton

class MsisdnUR: UIViewController, WKNavigationDelegate, URLSessionTaskDelegate {
//    let urUrl = NSURL(string: "https://auth-api-sandbox2.newton.pm/login/redirect/msisdn/start?application=www2.muchgossip.co.uk&waitingUrl=https%3A%2F%2Fstatic2.newton.pm%2Fjs%2Flatest%2Fexample%2Fmsisdn_login.html")!
    let urUrlMuchGossip = URL(string: "https://auth-api-sandbox2.newton.pm/login/redirect/msisdn/start?application=www2.muchgossip.co.uk&waitingUrl=https%3A%2F%2Fauth-api-sandbox2.newton.pm%2Flogin%2Fredirect%2Fmsisdn%2Ffinalize")!
    let urUrliFortuneLanding = URL(string: "http://ifortune2.playmobile.it/subscribe/?cr=63688&settrack=aaaasd")!
    let urUrliFortune = URL(string: "https://auth-api-sandbox.newton.pm/login/redirect/msisdn/start?application=ifortune2.playmobile.it&waitingUrl=https%3A%2F%2Fauth-api-sandbox.newton.pm%2Flogin%2Fredirect%2Fmsisdn%2Ffinalize")
    
    var urUrl: URL!  {
        if let txt = self.urlTextField.text , txt.count > 5,
            let url = URL(string: txt) {
            return url
        }
        return self.urUrliFortune
    }
    
    @IBOutlet weak var urlTextField: UITextField!
    
    let ssconfig = URLSessionConfiguration.default
    var session: Foundation.URLSession?
    
    @IBOutlet weak var debugLog: UITextView!
    
    override func viewDidLoad() {
        self.urlTextField.placeholder = urUrlMuchGossip.absoluteString
        
        self.debugLog.log("", overwrite: true)
        do {
            let isLogged = try Newton.getSharedInstance().isUserLogged()
            if isLogged {
                let userToken = try! Newton.getSharedInstance().getUserToken()
                self.debugLog.log("WARNING: User is Logged with User Token: \(userToken). You must Log Out before start MSISDN")
            } else {
                self.automaticRecognitionNewton()
            }
        } catch {
            self.debugLog.log("Error in MSISDN UR Flow \(error)")
        }
        super.viewDidLoad()
    }
    
    func getSession() -> Foundation.URLSession {
        if let session = self.session {
            return session
        }
        self.session = Foundation.URLSession(configuration: self.ssconfig, delegate: self, delegateQueue: nil)
        return self.session!
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.debugLog.log("Performing redirect to \(request.url!)")
        completionHandler(request)
    }
    
    func automaticRecognitionNewton() {
        debugLog.log("Starting automatic User Recognition...")
        do {
            try Newton.getSharedInstance()
                .getLoginBuilder()
                .setOnFlowCompleteCallback { error in
                    if let error = error {
                        self.debugLog.log("Error in MSISDN User Recognition Login Flow \(error)")
                    } else {
                        let userToken = try! Newton.getSharedInstance().getUserToken()
                        self.debugLog.log("MSISDN UR Login Flow completed correctly. User is Logged with User Token: \(userToken)")
                    }
                }
                .getMSISDNURLoginFlow()
                .startLoginFlow()
        } catch {
            self.debugLog.log("Error in MSISDN UR Login flow \(error)")
        }

    }

    @IBAction func requestUserRecognitionButtonPressed(_ sender: AnyObject) {
        debugLog.log("Starting URL: \(self.urUrl.absoluteString)")
        
        let task = self.getSession().dataTask(with: self.urUrl, completionHandler: { data, response, error in
            if let error = error {
                self.debugLog.log("Error in connection \(error)")
                return
            }
print("RESPONSE URL: \(String(describing: response?.url))")
            do {
                var jsonDict: [String: AnyObject]? = nil
                if let d = data , d.count > 0 {
                    jsonDict = try JSONSerialization.jsonObject(with: d, options: []) as? [String: AnyObject]
                }

                self.debugLog.log("response is \(String(describing: jsonDict))")
            } catch {
                self.debugLog.log("response malformed \(error)")
                if let d = data , d.count > 0 {
                    self.debugLog.log("\(String(describing: String(data: d, encoding: String.Encoding.utf8)))")
                }
            }
        }) 
        task.resume()
    }
    
    @IBAction func autoUserRecognitionButtonPressed(_ sender: AnyObject) {
        self.debugLog.log("starting automatic user number recognition process...")
        let wkconfig = WKWebViewConfiguration()
        let urWebView = WKWebView(frame: CGRect(x: 0.0, y: 60.0, width: self.view.frame.width, height: self.view.frame.height/3), configuration: wkconfig)
        urWebView.navigationDelegate = self
        
        urWebView.load(URLRequest(url: self.urUrl))
        self.view.addSubview(urWebView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debugLog.log("Progress: \(webView.estimatedProgress)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.debugLog.log("Error in navigation \(error)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.debugLog.log("Provisional navigation is started")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.debugLog.log("Error in provisional navigation \(error)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.debugLog.log("Navigation is finished")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        self.debugLog.log("A redirection has been received \(webView.url!)")
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.debugLog.log("Web view process is terminated")
    }

}
