import UIKit

class InventoryStorageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomAlertRefreshDelegate {
    func finishedAddingItem() {
        print("Finalalal")
        categorizedItems = StorageData.getInstance().categorizeStorage(storage?.items ?? [])
        inventoryStorageTableView.reloadData()
    }
    
    
    var inventoryViewController : InventoryViewController?
    
    
    var storage : Storage?
    var categorizedItems = [ExpiryCategory : [Item]]()
    var sections : [String]{
        var tempSections = [String]()
        let expiredItemsCount = categorizedItems[.expired]?.count ?? 0
        let todayItemsCount = categorizedItems[.today]?.count ?? 0
        let thisMonthItemsCount = categorizedItems[.thisMonth]?.count ?? 0
        let laterItemsCount = categorizedItems[.later]?.count ?? 0
//        print(expiredItemsCount)
//        print(todayItemsCount)
//        print(thisMonthItemsCount)
//        print(laterItemsCount)
        
        if expiredItemsCount > 0 {
            tempSections.append("Expired")
//            print("\(tempSections[tempSections.count-1]) appended")
        }
        if todayItemsCount > 0 {
            tempSections.append("Today")
//            print("\(tempSections[tempSections.count-1]) appended")

        }
        if thisMonthItemsCount > 0 {
            tempSections.append("This Month")
//            print("\(tempSections[tempSections.count-1]) appended")

        }
        if laterItemsCount > 0 {
            tempSections.append("Later")
//            print("\(tempSections[tempSections.count-1]) appended")

        }
        return tempSections
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let expiryCategory = StorageData.getInstance().getExpiryCategory(forString: sections[section])
//        print("\(expiryCategory) : \(categorizedItems[expiryCategory]?.count ?? 0)")
        return categorizedItems[expiryCategory]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = inventoryStorageTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InventoryStorageTableViewCell
        let expiryCategory = StorageData.getInstance().getExpiryCategory(forString: sections[indexPath.section])
        guard let items = categorizedItems[expiryCategory] else {return UITableViewCell()}
        
        let item = items[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        cell.itemQuantityLabel.text = "x\(item.quantity)"
        
        if sections[indexPath.section] == "Expired" {
            cell.itemExpiryLabel.textColor = .red
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let expiryCategory = StorageData.getInstance().getExpiryCategory(forString: sections[section])
        guard let items = categorizedItems[expiryCategory] else {return}
        print("\(items[indexPath.row].isExpired) \(items[indexPath.row])")
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
            
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 5, y: 0, width: tableView.frame.width - 30, height: 30)
        if sections[section] == "Expired" {
            titleLabel.textColor = .red
        }
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.text = sections[section]
        headerView.addSubview(titleLabel)
            
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    @IBOutlet var inventoryStorageTableView: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        if let storage = storage {
            categorizedItems = StorageData.getInstance().categorizeStorage(storage.items)
        }
        
        inventoryStorageTableView.dataSource = self
        inventoryStorageTableView.delegate = self
        if let storage = storage {
            self.title = storage.name
//            for item in storage.items{
//                print(item)
//            }
        }
        
//        navigationController?.addScanButton()
        
    }
    

}
