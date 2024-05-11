//
//  LoginNavigationController.swift
//  Stored
//
//  Created by student on 09/05/24.
//

import UIKit

class LoginNavigationController: UINavigationController {
    
    var storedTabBarController : StoredTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let loginViewController = children.first as? LoginViewController{
            loginViewController.storedTabBarController = self.storedTabBarController
        }
    }
    

}
