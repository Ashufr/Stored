import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, CustomAlertRefreshDelegate, QuickAddDelegate {
    func itemAdded() {
        inventoryTableView.reloadData()
        inventoryCollectionView.reloadData()
    }
    
    func finishedAddingItem() {
        inventoryNavigationController?.storedTabBarController?.expiringNavigationController?.expiringViewController!.reloadTable()
        inventoryTableView.reloadData()
        inventoryCollectionView.reloadData()
    }
    
    var inventoryStorageViewController : InventoryStorageViewController?
    var inventoryNavigationController : InventoryNavigationController?
    
    @IBOutlet var inventoryCollectionView: UICollectionView!
    @IBOutlet var inventoryTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryRecentlyCell", for: indexPath) as! InventoryTableViewCell
        return cell
        let item = recentlyAddedItems[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        if item.isExpired {
            cell.itemExpiryLabel.textColor = .red
        }
        cell.itemStorageLabel.text = item.storage
        if let image = item.image{
            cell.itemImage.image = image
        }else{
            ItemData.getInstance().loadImageFrom(url: item.imageURL){ image in
                if let image = image {
                    cell.itemImage.image = image
                    item.image = image
                } else {
                    // Handle case where image couldn't be loaded
                    print("Failed to load image")
                }
            }
        }
        cell.itemImage.layer.cornerRadius = 25
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = UserData.getInstance().user?.household?.storages.count ?? 0
        print("Inventory Collection count : \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InventoryCollectionCell", for: indexPath) as! InventoryCollectionViewCell
         
        guard let storage = UserData.getInstance().user?.household?.storages[indexPath.row] else {
            print("no storage found")
            return cell
        }
        cell.storageImage.image  = UIImage(named: storage.name)
        cell.storageName.text = storage.name
        cell.storageItemsCount.text = "\(storage.count)"
        cell.storageName.font = UIFont(name: "SFProRounded-Bold", size: 21)
        cell.storageItemsCount.font = UIFont(name: "SFProRounded-Bold", size: 21)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
        
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: inventoryCollectionView)
        if let indexPath = inventoryCollectionView.indexPathForItem(at: location){
            performSegue(withIdentifier: "StorageSegue", sender: indexPath)
        }
        
    }
    
    var recentlyAddedItems = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inventoryTableView.dataSource = self
        inventoryTableView.delegate = self
        inventoryTableView.isScrollEnabled = false
        
        let layout = generateGridLayout()
        inventoryCollectionView.delegate = self
        inventoryCollectionView.dataSource = self
        inventoryCollectionView.collectionViewLayout = layout
        // Do any additional setup after loading the view.
        inventoryCollectionView.isScrollEnabled = false
        
//        scanButton.setupUI(in: view)
//        navigationController?.addScanButton()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "StorageSegue" {
            if let indexPath = sender as? IndexPath{
                let storage = UserData.getInstance().user?.household?.storages[indexPath.row]
                if let destinationVC = segue.destination as? InventoryStorageViewController {
//                    print(storage)
                    destinationVC.storage = storage
                    destinationVC.inventoryViewController = self
                    self.inventoryStorageViewController = destinationVC
                }else{
//                    print(segue.destination as! InventoryStorageTableViewController)
                }
            }else {
                print(sender!)
            }
            
        }else{
            print(segue.identifier!)
        }
    }
    
    func generateGridLayout() -> UICollectionViewLayout {
        
        let padding : CGFloat = 10.0
        // Items dimension will be equal to group dimension
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        // Group dimension will have 1/4th of the section
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.31)), subitem: item, count: 2)
        
        group.interItemSpacing = .fixed(padding)

        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        
//        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
        
//        section.boundarySupplementaryItems = [generateHeader()]
        
        return UICollectionViewCompositionalLayout(section: section)
        
    }


}
