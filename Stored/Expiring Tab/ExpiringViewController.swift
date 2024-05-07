import UIKit

class ExpiringViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource, CustomAlertRefreshDelegate, QuickAddDelegate {
    func itemAdded() {
        print("Tabel refefefe")
        let items = HouseholdData.getInstance().house!.storages[4].items
        expiringCategorizedItems = StorageData.getInstance().categorizeExpiringItems(items)
        for (category, items) in expiringCategorizedItems {
            print(category)
            print(items)
        }
        expiringTableView.reloadData()
        expiringCollectionView.reloadData()
    }
    
    func finishedAddingItem() {
        print("Custom refreshs")
        guard let items = HouseholdData.getInstance().house?.storages[4].items  else {return}
        expiringCategorizedItems = StorageData.getInstance().categorizeExpiringItems(items)
        expiringTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expiringCategorizedItems[StorageData.getInstance().getExpiryCategory(forString: sections[section])]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expiringTableView.dequeueReusableCell(withIdentifier: "ExpiringTableViewCell", for: indexPath) as! ExpiringTableViewCell
        let expiryCategory = StorageData.getInstance().getExpiryCategory(forString: sections[indexPath.section])
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
        cell.itemImage.layer.cornerRadius = 25
        return cell
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
    
    var expiringNavigationController : ExpiringNavigationViewController?
    var expiringCategorizedItems : [ExpiryCategory: [Item]] = [:]
    var sections : [String]{
        var tempSections = [String]()
        let todayItemsCount = expiringCategorizedItems[.today]?.count ?? 0
        let tomorrowItemsCount = expiringCategorizedItems[.tomorrow]?.count ?? 0
        let thisWeekItemsCount = expiringCategorizedItems[.thisWeek]?.count ?? 0
        
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

        return tempSections
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
            let expiredItemsCount = HouseholdData.getInstance().house?.storages[4].items.filter { $0.isExpired }.count ?? 0
            cell.topLabel.text = "\(expiredItemsCount) Items"
            cell.bottomLabel.text = "Expired Items"
            cell.upperStackView.backgroundColor = upperStackColor
            cell.bottomView.backgroundColor = bottomContainerColor
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.addGestureRecognizer(tapGesture)
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        print("cell \(indexPath.row)")
        return cell
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform the segue programmatically
        let location = sender.location(in: expiringCollectionView)
        if let indexPath = expiringCollectionView.indexPathForItem(at: location){
            performSegue(withIdentifier: "ExpiredSegue", sender: indexPath)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = sender as? IndexPath{
            let storage = HouseholdData.getInstance().house?.storages[indexPath.row]
            if let destinationVC = segue.destination as? ExpiredViewController {
                destinationVC.expiringViewController = self
                self.expiredViewController = destinationVC
            }
        }
        
        
    }
    
//    @IBOutlet var homeTableView: UITableView!
    
    @IBOutlet var expiringCollectionView: UICollectionView!
    
    @IBOutlet var expiringTableView: UITableView!

    var expiredViewController : ExpiredViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = HouseholdData.getInstance().house?.storages[4].items ?? []
       
        expiringCategorizedItems = StorageData.getInstance().categorizeExpiringItems(items)
        expiringTableView.dataSource = self
        expiringTableView.delegate = self
        let layout = generateGridLayout()
        expiringCollectionView.delegate = self
        expiringCollectionView.dataSource = self
        expiringCollectionView.collectionViewLayout = layout
        expiringCollectionView.isScrollEnabled = false
        
        
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
