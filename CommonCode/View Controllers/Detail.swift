import UIKit
import Newton

class StateListener: UserStateChangeListener {
    let logFunction: LogFunction
    
    init(logFunction: @escaping LogFunction) {
        self.logFunction = logFunction
    }
    
    func onLoginStateChange(error: NWError?) {
        if let error = error {
            self.logFunction("User State Changed with Error: \(error)")
        } else  {
            self.logFunction("User State Changed")
        }
        do {
            let userToken = try! Newton.getSharedInstance().getUserToken()
            self.logFunction("User Token: \(userToken)")
            let isLogged = try Newton.getSharedInstance().isUserLogged()
            self.logFunction("User is Logged: \(isLogged)")
            if isLogged {
                try Newton.getSharedInstance().getUserMetaInfo { (error, metaInfo) -> () in
                    if let error = error {
                        self.logFunction("Error in retrieving User Meta Info: \(error)")
                    } else if let metaInfo = metaInfo {
                        self.logFunction("User Meta Info: \(metaInfo)")
                    }
                }
            }
        } catch {
            self.logFunction("Error in User Module \(error)")
        }
    }
}


class DetailViewController: UIViewController {
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var testSubtitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var debugLogTextView: UITextView!
    
    fileprivate var actions = [NewtonTestAction]()
    fileprivate var flushNotification = NWNotification.AnalyticEventsFlushed
    fileprivate var eventAddNotification = NWNotification.AnalyticEventAdded
    fileprivate var stateListener: StateListener?
    
    func debugLog(_ log: String) {
        self.debugLogTextView.log(log)
        print(log)
    }
    
    var model = NewtonTest() {
        didSet {
            self.actions = self.model.actions
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.debugLogTextView.log("", overwrite: true)

        self.testLabel.text = self.model.testName
        self.testSubtitle.text = self.model.testDescription
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
        }
        
        self.flushNotification.addNamedObserver(name: "detailFlushObserver", senderObject: nil) { error, notification in
            if let error = error {
                self.debugLog("Flush Notification Error: \(error)")
            } else if let userInfo = notification.userInfo {
                self.debugLog("Flush Notification: \(userInfo)")
            }
        }
        
        self.eventAddNotification.addNamedObserver(name: "detailAddEventObserver", senderObject: nil) { error, notification in
            if let error = error {
                self.debugLog("Add event Error: \(error)")
            } else if let userInfo = notification.userInfo {
                self.debugLog("Added event \(userInfo)")
            }
        }
        
        self.stateListener = StateListener(logFunction: self.debugLog)
        do {
            try Newton.getSharedInstance()
                .setOnUserStateChangeListener(listener: self.stateListener!)
            print("STATE CHANGE LISTENER SET")
        } catch {
            self.debugLog("Error on Setting State Change Listener :\(error)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.flushNotification.clearObserver(name: "detailFlushObserver")
        self.eventAddNotification.clearObserver(name: "detailAddEventObserver")
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonCell", for: indexPath) as! ButtonCell
        
        let action = self.actions[(indexPath as NSIndexPath).row]
        cell.setUp(action, logFunction: self.debugLog )
        return cell
    }
}

class ButtonCell: UICollectionViewCell {
    fileprivate var action = NewtonTestAction(identifier: "", action: { _ in })
    
    fileprivate var logFunction: LogFunction?
    
    func setUp(_ action: NewtonTestAction, logFunction: LogFunction?) {
        self.action = action
        self.logFunction = logFunction
        
        let actionIdentifier = action.identifier
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(actionIdentifier, for: UIControl.State())
        button.addTarget(self, action: #selector(ButtonCell.buttonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: ["button": button])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: ["button": button])
        
        self.contentView.addConstraints(constraints)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.action.preAction()
        self.action.performAction(self.logFunction)
        self.action.postAction(true)
    }
}
