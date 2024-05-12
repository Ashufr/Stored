//
//  LoginViewController.swift
//  Stored
//
//  Created by student on 09/05/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var storedTabBarController : StoredTabBarController?
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Error Signinig User")
                print(error!)
                return
            }
            let user = result.user
            DatabaseManager.shared.getUserFromDatabase(email: email) { user,householdCode in
                if let user = user {
                    if let code = householdCode {
                        DatabaseManager.shared.fetchHouseholdData(for: code) { household in
                            if let household = household {
                                user.household = household
                                UserData.getInstance().user = user
                                
                                strongSelf.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                                strongSelf.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                                DatabaseManager.shared.observeAllStorages(user : user ,for: household.code)
                                
                                print("assisgend")
                            } else {
                                strongSelf.performSegue(withIdentifier: "JoinCreateSegue", sender: user)
                                print("Failed to fetch household data")
                            }
                        }
                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    }else{
                        print("user no huse")
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

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            loginButtonTapped()
        }
        return true
    }
}
