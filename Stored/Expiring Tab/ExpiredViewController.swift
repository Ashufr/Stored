import UIKit

class ExpiredViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Storage.all.items.filter({$0.isExpired}).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expiredTableView.dequeueReusableCell(withIdentifier: "ExpiredTableViewCell", for: indexPath) as! ExpiredTableViewCell
        let items = Storage.all.items.filter({$0.isExpired})
        let item = items[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemDescriptionLabel.text = item.expiryDescription
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
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = expiredCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpiredCollectionViewCell", for: indexPath) as! ExpiredCollectionViewCell
        if indexPath.row == 0 {
            cell.topLabel.text = "1kg"
            cell.bottomLabel.text = "Of food wasted"
        }else{
            cell.topLabel.text = "₹935"
            cell.bottomLabel.text = "Money wasted"
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    

    @IBOutlet var expiredCollectionView: UICollectionView!
    @IBOutlet var expiredTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expiredCollectionView.dataSource = self
        expiredCollectionView.delegate = self
        expiredCollectionView.collectionViewLayout = generateGridLayout()
        expiredCollectionView.isScrollEnabled = false
        expiredTableView.dataSource = self
        expiredTableView.delegate = self
        // Do any additional setup after loading the view.
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
