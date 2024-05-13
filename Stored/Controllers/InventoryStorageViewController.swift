import UIKit

class InventoryStorageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomAlertRefreshDelegate, QuickAddDelegate, UIContextMenuInteractionDelegate {
    
    func itemAdded() {
        
        categorizedItems = StorageLocationData.getInstance().categorizeStorageItems(storage?.items ?? [])
        inventoryStorageTableView.reloadData()
    }
    
    func finishedAddingItem() {
        print("Finalalal")
        categorizedItems = StorageLocationData.getInstance().categorizeStorageItems(storage?.items ?? [])
        inventoryStorageTableView.reloadData()
    }
    
    
    var inventoryViewController : InventoryViewController?
    
    
    var storage : StorageLocation?
    var categorizedItems = [ExpiryCategory : [Item]]()
    var sections : [String] = []
    
    func getSections() -> [String]{
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
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
//        print("\(expiryCategory) : \(categorizedItems[expiryCategory]?.count ?? 0)")
        return categorizedItems[expiryCategory]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = inventoryStorageTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InventoryStorageTableViewCell
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[indexPath.section])
        guard let items = categorizedItems[expiryCategory] else {return UITableViewCell()}
        
        let item = items[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        cell.itemQuantityLabel.text = "x\(item.quantity)"
        
        if sections[indexPath.section] == "Expired" {
            cell.itemExpiryLabel.textColor = .red
        }
        if let image = item.image{
            cell.itemImage.image = image
            print("Image Found")
        }else{
            if item.imageURL?.absoluteString.contains("firebasestorage.googleapis.com") ?? false{
                StorageManager.shared.getImageFromURL(item.imageURL!.absoluteString){image in
                    if let image = image {
                        cell.itemImage.image = image
                        item.image = image
                    }
                }
            }else{
                ItemData.getInstance().loadImageFrom(url: item.imageURL){ image in
                    if let image = image {
                        cell.itemImage.image = image
                        item.image = image
                        print("Image Sett")
                    } else {
                        
                    }
                }
            }
        }
        cell.inventoryStorageController = self
        cell.itemImage.layer.cornerRadius = 25
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
            cell.addInteraction(contextMenuInteraction)
        
        return cell
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            guard let cell = interaction.view as? InventoryStorageTableViewCell else { return nil }
            guard let indexPath = inventoryStorageTableView.indexPath(for: cell) else { return nil }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteItem(at: indexPath)
            }
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                // Handle edit action
                // For example, you can call a method to present an edit view controller
                self.editItem(at: indexPath)
            }

            // Create and return the context menu configuration
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "", children: [deleteAction, editAction])
            }
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Perform the deletion here
                let section = indexPath.section
                let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
                guard var items = categorizedItems[expiryCategory] else { return }
                
                
                let item = items[indexPath.row]
                
                // Remove the item from storage.items
//                if let index = storage?.items.firstIndex(where: { $0 === item }) {
//                    storage?.items.remove(at: index)
//                }
//                if let index = UserData.getInstance().user?.household.storages[4].items.firstIndex(where: { $0 === item }) {
//                    StorageLocationData.getInstance().storages[4].items.remove(at: index)
//                }
//                inventoryViewController?.inventoryNavigationController?.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
//                inventoryViewController?.inventoryCollectionView.reloadData()
                
                // Remove the item from the categorizedItems dictionary
//                items.remove(at: indexPath.row)
//                categorizedItems[expiryCategory] = items
                
                // Delete the row from the table view
                deleteItem(at: indexPath)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                if (items.isEmpty){
//                    self.sections = getSections()
//                    self.categorizedItems = StorageLocationData.getInstance().categorizeStorageItems(UserData.getInstance().user?.household?.storages[4].items ?? [])
//                    tableView.reloadData()
//                }
                print("Deleted item: \(item)")
            }
        }
    
    func editItem(at indexPath : IndexPath){
        guard let customAlertController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomAlertVC") as? CustomAlertController else {
            return
        }
            
        let section = indexPath.section
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
        guard var items = categorizedItems[expiryCategory] else { return }
        
        
        let item = items[indexPath.row]
        
        customAlertController.productTitle = item.name
        customAlertController.productImageUrl = item.imageURL?.absoluteString
        customAlertController.productImage = item.image
        customAlertController.productExpiry = item.expiryDate
        let index = StorageLocationData.getInstance().getStorageIndex(for: item.storage)
        print(index)
        customAlertController.productStorageIndex = index
        customAlertController.productQuanity = item.quantity
        customAlertController.productDateAdded = item.dateAdded
        customAlertController.itemId = item.itemId
        customAlertController.oldStorage = item.storage
        customAlertController.modalTransitionStyle = .crossDissolve
        customAlertController.modalPresentationStyle = .overFullScreen
        customAlertController.inventoryStorageTableDelegate = self
        customAlertController.inventoryCollectionDelegate = inventoryViewController
        customAlertController.isUpdating = true
        customAlertController.expiringDelegate = self
            
        present(customAlertController, animated: true, completion: nil)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        print("dekete")
        let section = indexPath.section
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
        guard var items = categorizedItems[expiryCategory] else { return }
        
        let item = items[indexPath.row]
        
        DatabaseManager.shared.deleteItem(householdCode: UserData.getInstance().user?.household?.code ?? "", for: item){_ in 
            
        }
        inventoryViewController?.inventoryNavigationController?.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
        inventoryViewController?.inventoryCollectionView.reloadData()
        
//        inventoryStorageTableView.deleteRows(at: [indexPath], with: .fade)
        // Perform any additional deletion operations here, such as updating the backend
        
        // For demonstration purposes, you can print the deleted item
        print("Deleted item: \(item)")
    }


    @IBOutlet var inventoryStorageTableView: UITableView!
    

    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        if let storage = storage {
            categorizedItems = StorageLocationData.getInstance().categorizeStorageItems(storage.items)
        }
        sections = getSections()
        
        
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
