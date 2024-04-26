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

    @IBOutlet var popupView: UIView!
    
    @IBOutlet weak var OkBtn: UIButton!
    
    var isPopupVisible = false
    var popupShown = false
    var shouldPopUpShow = 0
    
  
    
    // Overlay view for dimming effect
        lazy var overlayView: UIView = {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.alpha = 0
            return view
        }()
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           let searchController = UISearchController(searchResultsController: nil)
           self.navigationItem.searchController = searchController
           quickAddTableView.dataSource = self
           quickAddTableView.delegate = self
           quickAddTableView.layer.cornerRadius = 10
           quickAddTableView.clipsToBounds = true
           
        popupView.isHidden = true
        popupView.layer.cornerRadius = 10
 
        // Add overlay view to the top of the view hierarchy
               view.addSubview(overlayView)
               view.sendSubviewToBack(overlayView)
        
        
           // Add observer for cell height update
           NotificationCenter.default.addObserver(self, selector: #selector(updateCellHeight), name: NSNotification.Name(rawValue: "UpdateCellHeight"), object: nil)
        
        
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
            if(image == UIImage(systemName: "plus.circle")) {
                // isPopupVisible.toggle()
                popupView.isHidden = !isPopupVisible
                
                // If the pop-up view is visible, center it above the table
                if isPopupVisible {
                    centerPopupView()
                }
                
            }
            if(image == UIImage(systemName: "checkmark.circle.fill")) {
                if(shouldPopUpShow == 0) { shouldPopUpShow = 1 }
                else if shouldPopUpShow == 1 {
                    shouldPopUpShow = 0
                    isPopupVisible.toggle()
          
                    popupView.isHidden = !isPopupVisible
                    
                    // If the pop-up view is visible, center it above the table
                    if isPopupVisible {
                        centerPopupView()
                    }
                }
            }
        } else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
                self.overlayView.alpha = self.isPopupVisible ? 1 : 0
                self.quickAddTableView.alpha = self.isPopupVisible ? 0.5 : 1
            }
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard sender.currentImage == UIImage(systemName: "plus.circle") else {
             return // If the button is not a plus circle, return without further action
         }
         
         // Call the method only when the button is a plus circle
         rightEndTickButtonTapped(sender)
    }
    
    
    @IBAction func okTapped(_ sender: Any) {
        
        popupView.isHidden = true
        
        // Hide overlay view when the pop-up view is dismissed
               UIView.animate(withDuration: 0.3) {
                   self.overlayView.alpha = 0
               }
        
        isPopupVisible = false
    }
    
    private func centerPopupView() {
            guard let tableViewSuperview = quickAddTableView.superview else { return }
            
            let tableCenterX = tableViewSuperview.bounds.midX
            let tableCenterY = tableViewSuperview.bounds.midY
            let popupWidth = popupView.bounds.width
            let popupHeight = popupView.bounds.height
            let popupX = tableCenterX - (popupWidth / 2)
            let popupY = tableCenterY - (popupHeight / 2)
            
            popupView.frame = CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight)
        }
       // Action method for handling "+" button tap
       @objc func updateCellHeight() {
           DispatchQueue.main.async {
               self.quickAddTableView.beginUpdates()
               self.quickAddTableView.endUpdates()
           }
       }
    
    
   
    
}
