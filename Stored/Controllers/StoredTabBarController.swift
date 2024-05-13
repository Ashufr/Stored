//
//  StoredTabBarController.swift
//  Stored
//
//  Created by student on 04/05/24.
//

import UIKit
import FirebaseAuth

class StoredTabBarController: UITabBarController {

    var expiringNavigationController : ExpiringNavigationViewController?
    var inventoryNavigationController : InventoryNavigationController?
    var quickAddNavigationController : QuickAddNavigationViewController?
    var householdNavigationController : HouseholdNavigationController?
    var accountNavigationController : AccountNavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DatabaseManager.shared.storedTabBarController  = self
        
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
        if let viewController = viewControllers?[3] as? HouseholdNavigationController {
            householdNavigationController = viewController
            viewController.storedTabBarController = self
            print("4 DOne")
        }
        if let viewController = viewControllers?[4] as? AccountNavigationController {
            accountNavigationController = viewController
            viewController.storedTabBarController = self
            print("5 DOne")
        }
    }
    
    
    
}
