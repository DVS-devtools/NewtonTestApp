import UIKit
import Newton

//com.changeringtone.deluxe || com.d-MobileLab.NewtonTestApp
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        do {
            let _ = try Newton.getSharedInstanceWithConfig(conf: "<sec_ret>", customData: NWSimpleObject(fromDictionary: ["aKey": "aValue"]))
        } catch {
            print("Newton initialization failed with error \(error)")
            return false
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EntryPoint") as? Orchestrator
        viewController!.launchOptions = launchOptions
        self.window!.rootViewController = viewController
        self.window!.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .setDeviceToken(token: deviceToken)
            print("Device token set into Newton")
        } catch {
            print("Newton Push Manager initialization failed with error \(error)")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error in push registration \(error)")
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .setRegistrationError(error: error)
        } catch {
            print("Newton Push Manager registration failed with error \(error)")
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .processLocalNotification(notification: notification)
        } catch {
            print("Newton Push Manager Local Push receipt failed with error \(error)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Remote Notification Reveived \(userInfo)")
        do {
            try Newton.getSharedInstance()
                .getPushManager()
                .processRemoteNotification(userInfo: userInfo as [AnyHashable: Any])
        } catch {
            print("Newton Push Manager Remote Push receipt failed with error \(error)")
        }
    }
}

