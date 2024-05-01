import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, CustomAlertRefreshDelegate {
    func finishedAddingItem() {
        inventoryTableView.reloadData()
        inventoryCollectionView.reloadData()
    }
    
    var inventoryStorageViewController : InventoryStorageViewController?
    
    @IBOutlet var inventoryCollectionView: UICollectionView!
    @IBOutlet var inventoryTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ItemData.getInstance().recentlyAddedItems.count
            }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryRecentlyCell", for: indexPath) as! InventoryTableViewCell
        let item = ItemData.getInstance().recentlyAddedItems[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        if item.isExpired {
            cell.itemExpiryLabel.textColor = .red
        }
        cell.itemStorageLabel.text = item.storage
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        StorageData.getInstance().storages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InventoryCollectionCell", for: indexPath) as! InventoryCollectionViewCell
        let storage = indexPath.row < StorageData.getInstance().storages.count ? StorageData.getInstance().storages[indexPath.row] : Storage.all
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
                let storage = indexPath.row < StorageData.getInstance().storages.count ? StorageData.getInstance().storages[indexPath.row] : Storage.all
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
