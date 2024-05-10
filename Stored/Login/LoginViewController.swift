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
            print(user)
            DatabaseManager.shared.getUserFromDatabase(email: email) { user in
                if let user = user {
                    UserData.getInstance().user = user
                    
                } else {
                    // User data retrieval failed or user does not exist
                    print("Failed to retrieve user data.")
                }
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginRegisterSegue", let destinationVC = segue.destination as? RegisterViewController {
            destinationVC.storedTabBarController = self.storedTabBarController
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ener")
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            loginButtonTapped()
        }
        return true
    }
}
