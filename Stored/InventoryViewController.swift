//
//  InventoryViewController.swift
//  Stored
//
//  Created by student on 24/04/24.
//

import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryRecentlyCell", for: indexPath) as! InventoryTableViewCell
        let item = items[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        cell.itemStorageLabel.text = item.storage
        return cell
    }
    
    let storages = [Storage(name: "Pantry", count: 4), Storage(name: "Fridge", count: 7), Storage(name: "Freezer", count: 2), Storage(name: "Shelf", count: 8), Storage(name: "All", count: 21)]
    
    @IBOutlet var invenctoryCollectionView: UICollectionView!
    @IBOutlet var inventoryTableView: UITableView!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        storages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InventoryCollectionCell", for: indexPath) as! InventoryCollectionViewCell
        let storage = storages[indexPath.row]
        cell.storageImage.image  = UIImage(named: storage.name)
        cell.storageName.text = storage.name
        cell.storageItemsCount.text = "\(storage.count)"

        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inventoryTableView.dataSource = self
        inventoryTableView.delegate = self
        inventoryTableView.isScrollEnabled = false
        
        let layout = generateGridLayout()
        invenctoryCollectionView.delegate = self
        invenctoryCollectionView.dataSource = self
        invenctoryCollectionView.collectionViewLayout = layout
        // Do any additional setup after loading the view.
        invenctoryCollectionView.isScrollEnabled = false
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
