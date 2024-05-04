//
//  StoredTabBarController.swift
//  Stored
//
//  Created by student on 04/05/24.
//

import UIKit

class StoredTabBarController: UITabBarController {

    var expiringNavigationController : ExpiringNavigationViewController?
    var inventoryNavigationController : InventoryNavigationController?
    var quickAddNavigationController : QuickAddNavigationViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewController = viewControllers?[0] as? ExpiringNavigationViewController {
            expiringNavigationController = viewController
            viewController.storedTabBarController = self
            print("1 DOne")
        }
        if let viewController = viewControllers?[1] as? InventoryNavigationController {
            inventoryNavigationController = viewController
            viewController.storedTabBarController = self
            print("2 DOne")
        }
        if let viewController = viewControllers?[2] as? QuickAddNavigationViewController {
            quickAddNavigationController = viewController
            viewController.storedTabBarController = self
            print("3 DOne")
        }
    }
    
}
