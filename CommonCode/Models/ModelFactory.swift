import Foundation
import Newton

class NWUtils {
    class var charset: [String] {
        return Array(65...90).map {String(UnicodeScalar($0))}
    }
    
    class func generateRandomString(length: Int) -> String {
        
        func randomLetter(charset: [String]) -> String {
            let randomIndex = arc4random_uniform(
                UInt32(charset.count))
            return charset[Int(randomIndex)]
        }
        
        var randStr = ""
        let charsetArray = NWUtils.charset
        for _ in 0..<length {
            randStr.append(randomLetter(charset: charsetArray))
        }
        return randStr
    }
}

struct ModelFactory {
    fileprivate let newtonInstance: Newton
    
    init?() {
        do {
            self.newtonInstance = try Newton.getSharedInstance()
        } catch {
            print("Error getting Newton Instance: \(error)")
            return nil
        }
    }
    
    func setupModels() -> [NewtonTest] {
        return [
            self.customLoginTestModel(),
//            self.oAuthLoginTestModel(),
            self.externalLoginTestModel(),
            self.logoutTestModel(),
            self.getUserMetaInfoTestModel(),
            self.syncUserStateTestModel(),
            self.deleteUserTestModel(),
            self.eventsCustomData(),
            self.eventsFlowTestModel(),
            self.eventsTimedTestModel(),
            self.eventsRankContent(),
            self.eventsAttachMasterSession(),
            self.eventsBulkCustomData(),
            self.isPayingForDefaultTestModel()
        ]
    }
}

private extension ModelFactory {
    func customLoginTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Custom Login Flow", description: "A Custom login with identifier Foo")
        
        let title = "Custom Login"
        let action: (LogFunction?) -> () = { logFunction in
            do {
                let builder = self.newtonInstance.getLoginBuilder()
                    .setCustomData(cData: NWSimpleObject(fromDictionary: ["aString": "aValue"])!)
                    .setCustomID(customId: "Foo")
                    .setOnFlowCompleteCallback { error in
                    if error != nil {
                        logFunction?("Login Flow completed with Error: \(String(describing: error))")
                    } else {
                        logFunction?("Login Flow went well")
                    }
                }
                
                let customLoginFlow = try builder.getCustomLoginFlow()
                customLoginFlow.startLoginFlow()
                
            } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
                logFunction?("Newton not initialized: \(String(describing: reason))")
            } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
                logFunction?("Login builder Error: \(String(describing: reason))")
            } catch {
                logFunction?("Unknown Error: \(error)")
            }
        }
        
        let customLoginTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([customLoginTestAction])
        
        return newtonTest
    }
    
//    func oAuthLoginTestModel() -> NewtonTest {
//        var newtonTest = NewtonTest(testName: "OAuth Login Flow", description: "Use System Facebook Account to perform Login with Newton")
//
//        let title = "OAuth Login"
//        let action: (LogFunction?) -> () = { logFunction in
//            do {
//                let builder = self.newtonInstance.getLoginBuilder()
//                    .setOAuthClientID(clientId: "430032157194398")
//                    .setOAuthProvider(provider: OAuthProvider(provider: OAuthProvider._Provider.Facebook))
//                    .setOnFlowCompleteCallback { error in
//                    // dispatch to main thread to safely deal with UIKit
//                    DispatchQueue.main.async { () -> Void in
//                        if let error = error {
//                            logFunction?("Login Flow completed with Error: \(error)")
//                        } else {
//                            logFunction?("Login Flow went well")
//                        }
//                    }
//                }
//
//                let oAuthFlow = try builder.getOAuthLoginFlow()
//                oAuthFlow.startLoginFlow()
//           } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
//                logFunction?("Newton not initialized: \(String(describing: reason))")
//            } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
//                logFunction?("Login builder Error: \(String(describing: reason))")
//            } catch {
//                logFunction?("Unknown Error: \(error)")
//            }
//        }
//
//        let oAuthLoginTestAction = NewtonTestAction(identifier: title, action: action)
//        newtonTest.addActions([oAuthLoginTestAction])
//
//        return newtonTest
//    }
    
    func getUserMetaInfoTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "User Meta Info", description: "Gather User Meta Info")
        
        let title = "User Meta Info"
        let action: (LogFunction?) -> () = { logFunction in
            self.newtonInstance.getUserMetaInfo() { (error, metaInfo) -> () in
                if let error = error {
                    logFunction?("User Meta Info completed with Error: \(error)")
                } else {
                    logFunction?("User Meta Info gathered \(metaInfo!)")
                }
            }
        }
        
        let metaInfoTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([metaInfoTestAction])
        
        return newtonTest
    }
    
    func logoutTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "User Logout", description: "Logout and clean all the user data")
        
        let title = "Logout"
        let action: (LogFunction?) -> () = { logFunction in
            self.newtonInstance.userLogout()
            logFunction?("User has been logged out")
        }
        
        let logoutTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([logoutTestAction])
        
        return newtonTest
    }
    
    func syncUserStateTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Sync User State", description: "Syncronize User state with Newton Server")
        
        let title = "Sync"
        let action: (LogFunction?) -> () = { logFunction in
            self.newtonInstance.syncUserState { error in
                if let error = error {
                    logFunction?("Sync User State completed with Error: \(error)")
                } else {
                    logFunction?("Sync User State went well")
                }
            }
        }
        let syncTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([syncTestAction])
        
        return newtonTest
    }
    
    func deleteUserTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "__TEMPORARY User Delete", description: "A call to the temporary API wich removes the user and logs him out")
        
        let title = "__TEMPORARY Delete"
        let action: (LogFunction?) -> () = { logFunction in
            self.newtonInstance.__temporaryUserDelete { error in
                if let error = error {
                    logFunction?("Delete User completed with Error: \(error)")
                } else {
                    logFunction?("Delete User went well")
                }
            }
        }
        let deleteTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([deleteTestAction])
        
        return newtonTest
    }
    
    func eventsCustomData() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Analytic Custom Event", description: "Send custom events towards newton")
        
        let title = "Custom Event"
        let action: (LogFunction?) -> () = { logFunction in
            do {
                let dict = ["aString": "bar", "aNumber": 10, "aFloat": 4.79, "aBool": true, "aNull": NSNull()] as [String : Any]
                try self.newtonInstance.sendEvent(name: "event_\(NWUtils.generateRandomString(length: 5))", customData: NWSimpleObject(fromDictionary: dict))
            } catch {
                logFunction?("Flow Begin Error: \(error)")
            }
        }
        let testAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([testAction])
        
        return newtonTest
    }

    func eventsBulkCustomData() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Analytic Custom Event [Bulk]", description: "Send a bulk of custom event towards newton")
        
        let title = "Bulk Custom Event"
        var bulk_idx = 0
        let action: (LogFunction?) -> () = { logFunction in
            logFunction?("Bulk no. \(bulk_idx)")
            for idx in 0 ..< 1000 {
                do {
                    try self.newtonInstance.sendEvent(name: "event\(bulk_idx)_\(idx)", customData: nil)
                    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
                } catch {
                    logFunction?("Bulk custom Error: \(error)")
                }
            }
            bulk_idx = bulk_idx + 1
        }
        let testAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([testAction])
        
        return newtonTest
    }

    
    func eventsFlowTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Analytic Flow", description: "Send analytic flow events towards newton (begin - step#i - succeed - cancel - fail)")
        
        let titleBegin = "Begin Flow"
        let actionBegin: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowBegin(name: "Test_Flow")
            } catch {
                logFunction?("Flow Begin Error: \(error)")
            }
        }
        
        let beginFlowTestAction = NewtonTestAction(identifier: titleBegin, action: actionBegin)
        
        let titleFirstStep = "Step 1 Flow"
        let actionFirstStep: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowStep(name: "Step_1")
            } catch {
                logFunction?("Flow Step Error: \(error)")
            }
        }
        
        let stepOneTestAction = NewtonTestAction(identifier: titleFirstStep, action: actionFirstStep)
        
        let titleSecondStep = "Step 2 Flow"
        let actionSecondStep: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowStep(name: "Step_2")
            } catch {
                logFunction?("Flow Step Error: \(error)")
            }
        }
        
        let stepTwoTestAction = NewtonTestAction(identifier: titleSecondStep, action: actionSecondStep)
        
        let titleSucceed = "Succeed"
        let actionSucceed: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowSucceed()
            } catch {
                logFunction?("Flow Step Error: \(error)")
            }
        }
        
        let succeedTestAction = NewtonTestAction(identifier: titleSucceed, action: actionSucceed)
        
        let titleCancel = "Cancel"
        let actionCancel: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowCancel(reason: "Cancel")
            } catch {
                logFunction?("Flow Step Error: \(error)")
            }
        }
        
        let cancelTestAction = NewtonTestAction(identifier: titleCancel, action: actionCancel)
        
        let titleFail = "Fail"
        let actionFail: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.flowFail(reason: "test_Fail")
            } catch {
                logFunction?("Flow Step Error: \(error)")
            }
        }
        
        let failTestAction = NewtonTestAction(identifier: titleFail, action: actionFail)
        
        
        let titleIsFlowRunning = "Is Flow Begun?"
        let actionIsFlowRunning: (LogFunction?) -> () = { logFunction in
            let answer = self.newtonInstance.isAnalyticFlowBegun()
            logFunction?("Analytic Flow is running: \(answer)")
        }
        let isFlowRunningTestAction = NewtonTestAction(identifier: titleIsFlowRunning, action: actionIsFlowRunning)

        newtonTest.addActions([beginFlowTestAction, stepOneTestAction, stepTwoTestAction, succeedTestAction, cancelTestAction, failTestAction, isFlowRunningTestAction])
        
        return newtonTest
    }
    
    func eventsTimedTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Timed Event Flow", description: "Send analytic timed events towards newton (start - stop)")
        
        let titleStartA = "Start A"
        let actionStartA: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.timedEventStart(name: "A")
            } catch {
                logFunction?("Timed Event Error: \(error)")
            }
        }
        
        let startATimedTestAction = NewtonTestAction(identifier: titleStartA, action: actionStartA)

        let titleStopA = "Stop A"
        let actionStopA: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.timedEventStop(name: "A")
            } catch {
                logFunction?("Timed Event Error: \(error)")
            }
        }
        
        let stopATimedTestAction = NewtonTestAction(identifier: titleStopA, action: actionStopA)

        let titleStartB = "Start B"
        let actionStartB: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.timedEventStart(name: "B")
            } catch {
                logFunction?("Timed Event Error: \(error)")
            }
        }
        
        let startBTimedTestAction = NewtonTestAction(identifier: titleStartB, action: actionStartB)
        
        let titleStopB = "Stop B"
        let actionStopB: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.timedEventStop(name: "B")
            } catch {
                logFunction?("Timed Event Error: \(error)")
            }
        }
        
        let stopBTimedTestAction = NewtonTestAction(identifier: titleStopB, action: actionStopB)
        
        let titleIsARunning = "Is A Running?"
        let actionIsARunning: (LogFunction?) -> () = { logFunction in
            let answer = self.newtonInstance.isTimedEventRunning(name: "A")
            logFunction?("Timer A is running: \(answer)")
        }
        let isARunningTestAction = NewtonTestAction(identifier: titleIsARunning, action: actionIsARunning)
        
        newtonTest.addActions([startATimedTestAction, stopATimedTestAction, startBTimedTestAction, stopBTimedTestAction, isARunningTestAction])
        
        return newtonTest
    }
    
    func eventsRankContent() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Analytic Rank Content Event", description: "Send ranking events towards newton")
        
        let titleSocial = "Rank Social Content Event"
        let actionSocial: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .social))
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionSocial = NewtonTestAction(identifier: titleSocial, action: actionSocial)
        
        let titleEditorial = "Rank Editorial Content Event"
        let actionEditorial: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .editorial))
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionEditorial = NewtonTestAction(identifier: titleEditorial, action: actionEditorial)
        
        let titleConsume = "Rank Consumption Content Event"
        let actionConsume: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .consumption))
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionConsume = NewtonTestAction(identifier: titleConsume, action: actionConsume)
        
        let multiplier: Float = 3.5
        let titleMultipliedSocial = "Rank Social Content Event with Multiplier"
        let actionMultipliedSocial: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .social), multiplier: multiplier)
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionMultipliedSocial = NewtonTestAction(identifier: titleMultipliedSocial, action: actionMultipliedSocial)
        
        let titleMultipliedEditorial = "Rank Editorial Content Event with Multiplier"
        let actionMultipliedEditorial: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .editorial), multiplier: multiplier)
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionMultipliedEditorial = NewtonTestAction(identifier: titleMultipliedEditorial, action: actionMultipliedEditorial)
        
        let titleMultipliedConsume = "Rank Consumption Content Event with Multiplier"
        let actionMultipliedConsume: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.rankContent(contentId: "aContent", scope: RankingScope(scope: .consumption), multiplier: multiplier)
            } catch {
                logFunction?("Rank Content Error: \(error)")
            }
        }
        let testActionMultipliedConsume = NewtonTestAction(identifier: titleMultipliedConsume, action: actionMultipliedConsume)
        
        
        newtonTest.addActions([testActionSocial, testActionEditorial, testActionConsume, testActionMultipliedSocial, testActionMultipliedEditorial, testActionMultipliedConsume])
        
        return newtonTest
    }

    func externalLoginTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "External Login Flow", description: "An External login with identifier Foo")
        
        let title = "External Login"
        let action: (LogFunction?) -> () = { logFunction in
            do {
                let builder = self.newtonInstance.getLoginBuilder()
                    .setCustomData(cData: NWSimpleObject(fromDictionary: ["aString": "aValue"])!)
                    .setExternalID(externalId: "Foo")
                    .setOnFlowCompleteCallback{ error in
                    if error != nil {
                        logFunction?("Login Flow completed with Error: \(error!)")
                    } else {
                        logFunction?("Login Flow went well")
                    }
                }
                
                let externalLoginFlow = try builder.getExternalLoginFlow()
                externalLoginFlow.startLoginFlow()
                
            } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
                logFunction?("Newton not initialized: \(String(describing: reason))")
            } catch NWError.LocalError(code: .LoginBuilderError, let reason, _, _) {
                logFunction?("Login builder Error: \(String(describing: reason))")
            } catch {
                logFunction?("Unknown Error: \(error)")
            }
        }
        
        let externalLoginTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([externalLoginTestAction])
        
        return newtonTest
    }
    
    func eventsAttachMasterSession() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Analytic Attached Session Event", description: "Send Attach Session events towards newton")
        
        let titleOLD = "Attach Master session Event (OLD)"
        let actionOLD: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.attachMasterSession(masterSessionId: "masterSessionAttach", masterUserId: "A_masterUser")
            } catch {
                logFunction?("Attach Session Error: \(error)")
            }
        }
        let testActionOLD = NewtonTestAction(identifier: titleOLD, action: actionOLD)
        
        let titleM = "Attach session Type Master"
        let actionM: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.attachSession(attachedSessionId: "attachedSessionMster", attachedUserId: "C_attachedUser", attachType: .master)
            } catch {
                logFunction?("Attach Session Error: \(error)")
            }
        }
        let testActionM = NewtonTestAction(identifier: titleM, action: actionM)
        
        let titleP = "Attach session Type Peer"
        let actionP: (LogFunction?) -> () = { logFunction in
            do {
                try self.newtonInstance.attachSession(attachedSessionId: "attachedSessionPeer", attachedUserId: "E_attachedUser", attachType: .peer)
            } catch {
                logFunction?("Attach Session Error: \(error)")
            }
        }
        let testActionP = NewtonTestAction(identifier: titleP, action: actionP)
        
        newtonTest.addActions([testActionOLD, testActionM, testActionP])
        
        return newtonTest
    }
    
    func isPayingForDefaultTestModel() -> NewtonTest {
        var newtonTest = NewtonTest(testName: "Is Paying For Default", description: "Ask whether the user is subscribed")
        
        let title = "IsPayingForDefault"
        let action: (LogFunction?) -> () = { logFunction in
            do {
                let _ = try self.newtonInstance
                    .getPaymentManager()
                    .isUserPayingForDefault(callback: { (error, paymentObject) in
                        guard error == nil else {
                            logFunction?("Unknown Error: \(String(describing: error))")
                            return
                        }
                        logFunction?(paymentObject!.description)
                    })
            } catch NWError.LocalError(code: .NewtonNotInitialized, let reason, _, _) {
                logFunction?("Newton not initialized: \(String(describing: reason))")
            } catch {
                logFunction?("Unknown Error: \(error)")
            }
        }
        
        let isPayingForTestAction = NewtonTestAction(identifier: title, action: action)
        newtonTest.addActions([isPayingForTestAction])
        
        return newtonTest
    }
}
