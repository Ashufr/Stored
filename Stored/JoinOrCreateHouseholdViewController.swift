import UIKit

class JoinOrCreateHouseholdViewController: UIViewController, UITextFieldDelegate {
    
    var user: User?
    var storedTabBarController: StoredTabBarController?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        // Set the delegate for text fields
        nameTextField.delegate = self
        codeTextField.delegate = self
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return is pressed
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func createButtonTapped() {
        guard let name = nameTextField.text else {
            print("Enter Household Name")
            return
        }
        guard let user = self.user else {
            print("User not found")
            return
        }
        let house = Household(name: name)
        DatabaseManager.shared.insertHousehold(by : user , with: house) { success in
            if success {
                print("Created Successfully")
                DatabaseManager.shared.updateHousehold(for: user, with: house) { success in
                    if success {
                        user.household = house
                        UserData.getInstance().user = user
                        print(user.safeEmail)
                        print("Household updated successfully")
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 1, section: 0),IndexPath(row: 0, section: 0)], with: .automatic)
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                        DatabaseManager.shared.observeAllStorages(user: user, for: house.code)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Household Not Found", message: "The household you've been trying to access doesn't exist", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        print("Failed to update household")
                        
                    }
                }
                print(house.storages)
                
            }
        }
    }
    
    @IBAction func joinButtonTapped() {
        guard let code = codeTextField.text else { return }
        guard let user = self.user else {
            print("User not found")
            return
        }
        DatabaseManager.shared.fetchHouseholdData(for: code) { household in
            if let household = household {
                
                DatabaseManager.shared.updateHousehold(for: user, with: household) { success in
                    if success {
                        DatabaseManager.shared.observeAllStorages(user: user, for: code)
                        print("Household Joined successfully")
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                UserData.getInstance().user?.household = household
                print("Houshold after joining assigned")
                self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.dismiss(animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Household Not Found", message: "The household you've been trying to access doesn't exist", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                print("Failed to update household")
                
            }
        }
    }
}
