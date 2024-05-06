//
//  HouseholdNavigationController.swift
//  Stored
//
//  Created by student on 06/05/24.
//

import UIKit

class HouseholdNavigationController: UINavigationController {

    var householdViewController : HouseholdViewController?
    var storedTabBarController : StoredTabBarController?
    override func viewDidLoad() {
        super.viewDidLoad()
        findHouseholdController()
    }
    
    private func findHouseholdController() {
        print(viewControllers[0])
        guard let lastViewController = viewControllers.first as? HouseholdViewController else {
            return
        }
        householdViewController = lastViewController
        lastViewController.householdNavigationController = self
    }

}
