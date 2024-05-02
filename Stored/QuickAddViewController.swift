import UIKit

class QuickAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let items: [QItem] = [
        QItem(name: "Coca Cola", imageName: "coca_cola_image"),
        QItem(name: "Bonn Bread", imageName: "bonn_bread_image"),
        QItem(name: "Real Fruit Juice", imageName: "real_fruit_juice_image"),
        QItem(name: "Doritos", imageName: "doritos_image"),
        QItem(name: "Nutella Biscuits", imageName: "nutella_biscuits_image")
    ]

    @IBOutlet var quickAddTableView: UITableView!

    var shouldPopUpShow = 0
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           let searchController = UISearchController(searchResultsController: nil)
           self.navigationItem.searchController = searchController
           quickAddTableView.dataSource = self
           quickAddTableView.delegate = self
           quickAddTableView.layer.cornerRadius = 10
           quickAddTableView.clipsToBounds = true
           
        
        
       }

       deinit {
           // Remove observer
           NotificationCenter.default.removeObserver(self)
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return items.count
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickAddTableViewCell", for: indexPath) as! QuickAddTableViewCell
        let item = items[indexPath.row]
        cell.itemImage.image = UIImage(named: item.imageName)
        cell.itemNameLabel.text = item.name
        
        // Initially hide the "-" label and "+" button
        cell.showQuantityButtons = false
        
        // Set tags for buttons
        cell.itemAddButton.tag = indexPath.row
        cell.minusBtn.tag = indexPath.row
        cell.quantAddBtn.tag = indexPath.row
        
        return cell
    }

    @IBAction func rightEndTickButtonTapped(_ sender: UIButton) {
        print(sender.currentImage!)

        if let image = sender.currentImage {
                if image == UIImage(systemName: "checkmark.circle.fill") {
                    if shouldPopUpShow == 0 {
                        shouldPopUpShow = 1
                    } else if shouldPopUpShow == 1 {
                        shouldPopUpShow = 0
                            let itemName = items[sender.tag].name
                            let overLayer = OverLayerPopUp(itemName: itemName)
                            overLayer.appear(sender: self)
                           
                        
                    }
                }
            }
        else {
            return
        }
        
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard sender.currentImage == UIImage(systemName: "plus.circle") else {
             return // If the button is not a plus circle, return without further action
         }
         
         // Call the method only when the button is a plus circle
         rightEndTickButtonTapped(sender)
    }
    
    
    
       // Action method for handling "+" button tap
       @objc func updateCellHeight() {
           DispatchQueue.main.async {
               self.quickAddTableView.beginUpdates()
               self.quickAddTableView.endUpdates()
           }
       }
    
    
    
   
    
}
