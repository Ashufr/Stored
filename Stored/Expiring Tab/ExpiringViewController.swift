import UIKit
import FirebaseAuth

class ExpiringViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource, CustomAlertRefreshDelegate, QuickAddDelegate {
    func itemAdded() {
        print("Tabel refefefe")
        expiringCategorizedItems = StorageLocationData.getInstance().categorizeExpiringItems(UserData.getInstance().user?.household?.storages[4].items ?? [])
        upadateSections()
        expiringTableView.reloadData()
    }
    
    func finishedAddingItem() {
        print("Custom refreshs")
        expiringCategorizedItems = StorageLocationData.getInstance().categorizeExpiringItems(UserData.getInstance().user?.household?.storages[4].items ?? [])
        expiringTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expiringCategorizedItems[StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expiringTableView.dequeueReusableCell(withIdentifier: "ExpiringTableViewCell", for: indexPath) as! ExpiringTableViewCell
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[indexPath.section])
        guard let items = expiringCategorizedItems[expiryCategory] else {return UITableViewCell()}
        let item = items[indexPath.row]
        
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        cell.storageLabel.text = item.storage
        if let image = item.image{
            cell.itemImage.image = image
        }else{
            ItemData.getInstance().loadImageFrom(url: item.imageURL){ image in
                if let image = image {
                    cell.itemImage.image = image
                    item.image = image
                } else {
                    print("Failed to load image")
                }
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleItemTap(_:)))
        cell.addGestureRecognizer(tap)
        cell.itemImage.layer.cornerRadius = 25
        return cell
    }
    
    @objc func handleItemTap(_ sender: UITapGestureRecognizer){
//        let location = sender.location(in: expiringTableView)
//                if let tabBarController = self.tabBarController {
//                tabBarController.selectedIndex = 1 
//                    // Set desired tab index here
//            }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 5, y: 0, width: tableView.frame.width - 30, height: 30)
        
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
            guard var items = expiringCategorizedItems[expiryCategory] else { return }
            
            
            let item = items[indexPath.row]

            
            expiringNavigationController?.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
            // Remove the item from the categorizedItems dictionary
            items.remove(at: indexPath.row)
            expiringCategorizedItems[expiryCategory] = items
            
            // Delete the row from the table view
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            if (items.isEmpty){
                self.upadateSections()
                tableView.reloadData()
            }
            // Perform any additional deletion operations here, such as updating the backend
            
            // For demonstration purposes, you can print the deleted item
            print("Deleted item: \(item)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("sele")
        let section = indexPath.section
        let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
        guard var items = expiringCategorizedItems[expiryCategory] else { return }
        let item = items[indexPath.row]
        tabBarController?.selectedIndex = 1
        performSegue(withIdentifier: "StorageSegue", sender: IndexPath(item: StorageLocationData.getInstance().getStorageIndex(for: item.storage), section: 0))
    }
    
    var expiringNavigationController : ExpiringNavigationViewController?
    var expiringCategorizedItems : [ExpiryCategory: [Item]] = [:]
    var sections : [String] = []
    
    func upadateSections(){
        
        var tempSections = [String]()
        let todayItemsCount = expiringCategorizedItems[.today]?.count ?? 0
        let tomorrowItemsCount = expiringCategorizedItems[.tomorrow]?.count ?? 0
        let thisWeekItemsCount = expiringCategorizedItems[.thisWeek]?.count ?? 0
        //        print(expiredItemsCount)
        //        print(todayItemsCount)
        //        print(thisMonthItemsCount)
        //        print(laterItemsCount)
        
        if todayItemsCount > 0 {
            tempSections.append("Today")
            //            print("\(tempSections[tempSections.count-1]) appended")
            
        }
        if tomorrowItemsCount > 0 {
            tempSections.append("Tomorrow")
            //            print("\(tempSections[tempSections.count-1]) appended")
        }
        if thisWeekItemsCount > 0 {
            tempSections.append("This Week")
            //            print("\(tempSections[tempSections.count-1]) appended")
            
        }
        
        self.sections = tempSections
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = expiringCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpiringCollectionCell", for: indexPath) as! ExpiringCollectionViewCell
        if indexPath.row == 0 {
            let upperStackHexcode = "#78D444"
            let bottomContainerHexcode = "#E2F9A1"
            let upperStackColor = UIColor(hex: upperStackHexcode)
            let bottomContainerColor = UIColor(hex: bottomContainerHexcode)
            cell.topLabel.text = "6 Weeks"
            cell.bottomLabel.text = "Of #ZeroWaste"
            cell.upperStackView.backgroundColor = upperStackColor
            cell.bottomView.backgroundColor = bottomContainerColor
        }else{
            let upperStackHexcode = "#D70015"
            let bottomContainerHexcode = "#F4B7BD"
            let upperStackColor = UIColor(hex: upperStackHexcode)
            let bottomContainerColor = UIColor(hex: bottomContainerHexcode)
            let expiredItemsCount = StorageLocation.all.items.filter { $0.isExpired }.count
            cell.topLabel.text = "\(expiredItemsCount) Items"
            cell.bottomLabel.text = "Expired Items"
            cell.upperStackView.backgroundColor = upperStackColor
            cell.bottomView.backgroundColor = bottomContainerColor
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.addGestureRecognizer(tapGesture)
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform the segue programmatically
        performSegue(withIdentifier: "ExpiredSegue", sender: nil)
    }
    
    //    @IBOutlet var homeTableView: UITableView!
    
    @IBOutlet var expiringCollectionView: UICollectionView!
    
    @IBOutlet var expiringTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth(class : self)
        expiringCategorizedItems = StorageLocationData.getInstance().categorizeExpiringItems(UserData.getInstance().user?.household?.storages[4].items ?? [])
        upadateSections()
        expiringTableView.dataSource = self
        expiringTableView.delegate = self
        let layout = generateGridLayout()
        expiringCollectionView.delegate = self
        expiringCollectionView.dataSource = self
        expiringCollectionView.collectionViewLayout = layout
        expiringCollectionView.isScrollEnabled = false
        
        
    }
    
    func validateAuth(class : ExpiringViewController){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            print("not logged in")
            guard let loginNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationVC") as? LoginNavigationController else {
                return
            }
            loginNavigationViewController.modalPresentationStyle = .fullScreen
            loginNavigationViewController.storedTabBarController = expiringNavigationController?.storedTabBarController
           present(loginNavigationViewController, animated: true)
        }else {
            guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
                print("email not found")
                return
            }
            DatabaseManager.shared.getUserFromDatabase(email: email) { user, houseCode in
                if let user = user {
                    if let code = houseCode {
                        DatabaseManager.shared.observeUsersChanges(for: user, householdCode: code)
                        DatabaseManager.shared.fetchHouseholdData(for: code) { household in
                            if let household = household {
                                user.household = household
                                UserData.getInstance().user = user
                                
                                DatabaseManager.shared.observeAllStorages(user : user ,for: household.code)
                                print("assisgend")
                            } else {
                                print("Failed to fetch household data")
                            }
                        }
                        
                    }else{
                        print("Presenting create screen")
                        guard let joinOrCreateHouseholdViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinCreateVC") as? JoinOrCreateHouseholdViewController else {
                            return
                        }
                        joinOrCreateHouseholdViewController.user = user
                        joinOrCreateHouseholdViewController.modalPresentationStyle = .fullScreen
                        joinOrCreateHouseholdViewController.storedTabBarController = self.expiringNavigationController?.storedTabBarController
                        self.present(joinOrCreateHouseholdViewController, animated: true){
                            self.expiringNavigationController?.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                            
                        }
                        print("Done create screen")
                        
                    }
                } else {
                    print("User not found in Realtime Databaswe")
                    guard let loginNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationVC") as? LoginNavigationController else {
                        return
                    }
                    loginNavigationViewController.modalPresentationStyle = .fullScreen
                    loginNavigationViewController.storedTabBarController = self.expiringNavigationController?.storedTabBarController
                    self.present(loginNavigationViewController, animated: true)
                    print("Failed to retrieve user data.")
                }
            }
            
            
            
            
            
        }
    }
    
    func reloadTable(){
//        expiringCategorizedItems = StorageLocationData.getInstance().categorizeExpiringItems(StorageLocationData.getInstance().storages[4].items)
        expiringTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToStorageSegue" {
            if let indexPath = sender as? IndexPath {
                let section = indexPath.section
                let expiryCategory = StorageLocationData.getInstance().getExpiryCategory(forString: sections[section])
                guard var items = expiringCategorizedItems[expiryCategory] else { return }
                
                let item = items[indexPath.row]
//                let storage = StorageLocationData.getInstance().getStorage(for: item.storage)
//                if let destinationVC = segue.destination as? InventoryStorageViewController {
//                    destinationVC.storage = storage
//                }
            }
        }
    }
    
    
    
    func generateGridLayout() -> UICollectionViewLayout {
        
        let padding : CGFloat = 10.0
        // Items dimension will be equal to group dimension
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        // Group dimension will have 1/4th of the section
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9)), subitem: item, count: 2)
        
        group.interItemSpacing = .fixed(padding)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        
        //        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
        
        //        section.boundarySupplementaryItems = [generateHeader()]
        
        return UICollectionViewCompositionalLayout(section: section)
        
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
