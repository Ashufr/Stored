//
//  QuickAddViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

protocol QuickAddDelegate : AnyObject {
    func itemAdded()
}

class QuickAddViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var expiringDelegate : QuickAddDelegate?
    var inventoryDelegate : QuickAddDelegate?
    var quickAddNavigationController : QuickAddNavigationViewController?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ItemData.getInstance().quickAddItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = quickAddTableView.dequeueReusableCell(withIdentifier: "QuickAddTableViewCell", for: indexPath) as! QuickAddTableViewCell
        let item = ItemData.getInstance().quickAddItems[indexPath.row]
        cell.itemName.text = item.name
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
        cell.buttonImage.isUserInteractionEnabled = true
        cell.buttonImage.addGestureRecognizer(tapGesture)
        cell.item = item
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
        cell.quickAddViewController = self
        return cell
    }
    
    @objc func handleIconTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        guard let imageStack = imageView.superview as? UIStackView else {return}
        guard let OuterView = imageStack.superview else {return}
        guard let outerStack = OuterView.superview as? UIStackView else {return}
        
        guard let contentView = outerStack.superview else {return}

        guard let cell = contentView.superview as? QuickAddTableViewCell else {return}
        guard let item = cell.item else {return}

        if(!cell.itemStack.isHidden){
            if let image = UIImage(systemName: "plus.circle") {
                cell.buttonImage.image = image
            }else{
                print("No image")
            }
            cell.itemStack.isHidden = true
            if cell.itemStepper.value == 0 {
                return
            }

//            let storage = StorageLocationData.getInstance().getStorage(for: item.storage)
            let newItem = Item(quickAddItem: item, quantity : Int(cell.itemStepper.value) )
            
            
            DatabaseManager.shared.insertItem(with: newItem, householdCode: UserData.getInstance().user?.household?.code ?? "x", storageName: newItem.storage) { itemRef in
                if itemRef != nil {
//                    storage.items.append(newItem)
//                    StorageData.getInstance().storages[4].items.append(item)
                    self.quickAddNavigationController?.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                    self.quickAddNavigationController?.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                    self.quickAddNavigationController?.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
                    let alertController = UIAlertController(title: "Item Added", message: "\(newItem.name) x\(Int(cell.itemStepper.value)) has been added to your \(item.storage)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    // Get the topmost view controller to present the alert
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                            window.rootViewController?.present(alertController, animated: true, completion: nil)
                        }
                    }
                    self.inventoryDelegate?.itemAdded()
                    self.expiringDelegate?.itemAdded()
                    print("Item inserted successfully")
                } else {
                    
                    let alertController = UIAlertController(title: "Failed to add", message: "\(newItem.name) x\(Int(cell.itemStepper.value)) wasn't added to your \(item.storage)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    // Get the topmost view controller to present the alert
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                            window.rootViewController?.present(alertController, animated: true, completion: nil)
                        }
                    }
                    print("Failed to insert item")
                }
                cell.itemStepper.value = 1
                cell.itemStepperLabel.text = "1"
            }
            
            
            
            
        }else{
            if let image = UIImage(systemName: "checkmark.circle.fill") {
                cell.buttonImage.image = image
            }else{
                print("No image")
            }
            cell.itemStack.isHidden = false
        }
        
        inventoryDelegate = quickAddNavigationController!.storedTabBarController?.inventoryNavigationController?.inventoryViewController
        expiringDelegate = quickAddNavigationController?.storedTabBarController?.expiringNavigationController?.expiringViewController
    }
    
    func dismissAdding(cell : QuickAddTableViewCell){
        if let image = UIImage(systemName: "plus.circle") {
            cell.buttonImage.image = image
        }else{
            print("No image")
        }
        cell.itemStack.isHidden = true
    }
    

    @IBOutlet var quickAddTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        quickAddTableView.dataSource = self
        quickAddTableView.delegate = self
        quickAddTableView.allowsSelection = false
        quickAddTableView.isScrollEnabled = false
        // Do any additional setup after loading the view.
        
    }

}
