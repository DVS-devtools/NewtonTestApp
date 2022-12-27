import UIKit

class MasterViewController: UITableViewController {
    var tests: [NewtonTest] {
        if let modelFactory = ModelFactory() {
            return modelFactory.setupModels()
        } else {
            return [NewtonTest]()
        }
    }
    
    // MARK: - table view datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.tests[(indexPath as NSIndexPath).row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewtonCell", for: indexPath)
        cell.textLabel!.text = model.testName
        
        return cell
    }
    
    // MARK: - table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.storyboard,
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
        let navController = self.navigationController {
            let selectedModel = self.tests[(indexPath as NSIndexPath).row]
            detailViewController.model = selectedModel
            
            navController.pushViewController(detailViewController, animated: true)
        }
    }
}

