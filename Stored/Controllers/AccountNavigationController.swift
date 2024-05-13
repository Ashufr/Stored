//
//  AccountNavigationController.swift
//  Stored
//
//  Created by student on 06/05/24.
//

import UIKit

class AccountNavigationController: UINavigationController {
    

    var accountViewController : AccountViewController?
    var storedTabBarController : StoredTabBarController?
    override func viewDidLoad() {
        super.viewDidLoad()
        findAccountController()
    }
    
    private func findAccountController() {
        print(viewControllers[0])
        guard let lastViewController = viewControllers.first as? AccountViewController else {
            return
        }
        accountViewController = lastViewController
        lastViewController.accountNavigtionController = self
    }
}
