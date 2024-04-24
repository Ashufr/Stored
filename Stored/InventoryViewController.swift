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
        if item.isExpired {
            cell.itemExpiryLabel.textColor = .red
        }
        cell.itemStorageLabel.text = item.storage
        return cell
    }
    
    
    
    @IBOutlet var inventoryCollectionView: UICollectionView!
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
        
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("obgjd")
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StorageSegue" {
            if let indexPath = sender as? IndexPath{
                if let destinationVC = segue.destination as? InventoryStorageViewController {
                    print(storages[indexPath.row])
                    destinationVC.storage = storages[indexPath.row]
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
