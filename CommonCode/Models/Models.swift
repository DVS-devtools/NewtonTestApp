import Foundation
import Newton

struct NewtonTest {
    var testName: String
    var testDescription: String
    
    fileprivate var _actions = [NewtonTestAction]()
    var actions: [NewtonTestAction] {
        get {
            return self._actions
        }
    }
    
    init(testName: String = "Un-named Newton Test", description: String = "") {
        self.testName = testName
        self.testDescription = description
    }
    
    mutating func addActions(_ actions: [NewtonTestAction]) {
        self._actions = actions
    }
}

typealias LogFunction = (String) -> ()

struct NewtonTestAction {
    var identifier: String
    var action: (LogFunction?) -> ()
    var preAction: () -> () = {}
    var postAction: (Bool) -> () = { _ in }
    
    init(identifier: String, action: @escaping (LogFunction?) -> ()) {
        self.identifier = identifier
        self.action = action
    }
    
    func performAction(_ log: ((String) -> ())? = nil) {
        self.preAction()
        self.action(log)
        self.postAction(false)
    }
}
