import UIKit

class ExpiringViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = expiringCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpiringCollectionCell", for: indexPath) as! ExpiringCollectionViewCell
        if indexPath.row == 0 {
            let upperStackHexcode = "#78D444"
            let bottomContainerHexcode = "#E6F6CE"
            let upperStackColor = UIColor(hex: upperStackHexcode)
            let bottomContainerColor = UIColor(hex: bottomContainerHexcode)
            cell.topLabel.text = "6 Weeks"
            cell.bottomLabel.text = "Of #ZeroWaste"
            cell.upperStackView.backgroundColor = upperStackColor
            cell.bottomView.backgroundColor = bottomContainerColor
        }else{
            let upperStackHexcode = "#D70015"
            let bottomContainerHexcode = "#F4C1CA"
            let upperStackColor = UIColor(hex: upperStackHexcode)
            let bottomContainerColor = UIColor(hex: bottomContainerHexcode)
            let expiredItemsCount = Storage.all.items.filter { $0.isExpired }.count
            cell.topLabel.text = "\(expiredItemsCount) Items"
            cell.bottomLabel.text = "Expired Items"
            cell.upperStackView.backgroundColor = upperStackColor
            cell.bottomView.backgroundColor = bottomContainerColor
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    
    
//    @IBOutlet var homeTableView: UITableView!
    
    @IBOutlet var expiringCollectionView: UICollectionView!
    
    
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
//        homeTableView.dataSource = self
//        homeTableView.delegate = self
//        homeTableView.isScrollEnabled = false
        let layout = generateGridLayout()
        expiringCollectionView.delegate = self
        expiringCollectionView.dataSource = self
        expiringCollectionView.collectionViewLayout = layout
//        expiringCollectionView.isScrollEnabled = false
    }

    func generateGridLayout() -> UICollectionViewLayout {
        
        let padding : CGFloat = 10.0
        // Items dimension will be equal to group dimension
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        // Group dimension will have 1/4th of the section
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1)), subitem: item, count: 2)
        
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
