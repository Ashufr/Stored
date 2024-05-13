import UIKit
import FirebaseAuth

// MARK: - View Controller

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var storedTabBarController: StoredTabBarController?
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    // Store original position of the view
    var originalFrame: CGRect!
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerKeyboardNotifications()
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UI Configuration
    
    private func configureUI() {
        loginButton.layer.cornerRadius = 4
        logoImageView.layer.cornerRadius = 20
        
        // Set the delegate for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Register for tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Store the original frame of the view
        originalFrame = self.view.frame
        
        if let placeholder = emailTextField.placeholder {
            emailTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        if let placeholder = passwordTextField.placeholder {
            passwordTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
    }
    
    // MARK: Keyboard Handling
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            guard let result = authResult, error == nil else {
                print("Error Signing User")
                print(error!)
                return
            }
            let user = result.user
            DatabaseManager.shared.getUserFromDatabase(email: email) { user, householdCode in
                if let user = user {
                    if let code = householdCode {
                        DatabaseManager.shared.fetchHouseholdData(for: code) { household in
                            if let household = household {
                                user.household = household
                                UserData.getInstance().user = user
                                DatabaseManager.shared.observeAllStorages(user: user, for: household.code)
                                DatabaseManager.shared.observeUsersChanges(for: user, householdCode: household.code)
                                print("Assigned")
                            } else {
                                strongSelf.performSegue(withIdentifier: "JoinCreateSegue", sender: user)
                                print("Failed to fetch household data")
                            }
                        }
                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    } else {
                        print("User has no household")
                        strongSelf.performSegue(withIdentifier: "JoinCreateSegue", sender: user)
                    }
                } else {
                    print("Failed to retrieve user data.")
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let user = sender as? User, let destinationVC = segue.destination as? JoinOrCreateHouseholdViewController {
            destinationVC.user = user
            destinationVC.storedTabBarController = self.storedTabBarController
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
