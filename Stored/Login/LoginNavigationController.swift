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
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
