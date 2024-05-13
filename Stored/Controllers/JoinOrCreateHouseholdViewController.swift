import UIKit

class JoinOrCreateHouseholdViewController: UIViewController, UITextFieldDelegate {
    
    var user: User?
    var storedTabBarController: StoredTabBarController?
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    
    // Store original position of the view
    var originalFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        logoImageView.layer.cornerRadius = 20
        createButton.layer.cornerRadius = 4
        joinButton.layer.cornerRadius = 4
        // Set the delegate for text fields
        nameTextField.delegate = self
        codeTextField.delegate = self
        
        // Store the original frame of the view
        originalFrame = self.view.frame
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let placeholder = nameTextField.placeholder {
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        if let placeholder = codeTextField.placeholder {
            codeTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return is pressed
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Keyboard Handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // Adjust the frame of the view to move it up when the keyboard appears
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -(keyboardFrame.height / 2)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Restore the original frame of the view when the keyboard hides
        UIView.animate(withDuration: 0.3) {
            self.view.frame = self.originalFrame
        }
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
        DatabaseManager.shared.insertHousehold(by : user , with: house) { code in
            if let code = code {
                print("Created Successfully")
                house.code = code
                DatabaseManager.shared.observeUsersChanges(for: user, householdCode : code)
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
                        self.present(alertController, animated: true, completion: nil)
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
                DatabaseManager.shared.observeUsersChanges(for: user, householdCode : code)
                DatabaseManager.shared.updateHousehold(for: user, with: household) { success in
                    if success {
                        user.household = household
                        UserData.getInstance().user = user
                        DatabaseManager.shared.observeAllStorages(user: user, for: code)
                        print("Household Joined successfully")
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
                self.present(alertController, animated: true, completion: nil)
                print("Failed to update household")
            }
        }
    }
}
