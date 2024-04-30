import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var homeTableView: UITableView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ItemData.getInstance().recentlyAddedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        
        let item = ItemData.getInstance().recentlyAddedItems[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        if item.isExpired {
            cell.itemExpiryLabel.textColor = .red
        }
        cell.storageLabel.text = item.storage
        return cell
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.dataSource = self
        homeTableView.delegate = self
//        homeTableView.isScrollEnabled = false
        // Do any additional setup after loading the view.
    }


}

