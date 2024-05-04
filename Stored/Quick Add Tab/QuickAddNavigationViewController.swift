//
//  QuickAddNavigationViewController.swift
//  Stored
//
//  Created by student on 04/05/24.
//

import UIKit

class QuickAddNavigationViewController: UINavigationController {

    var quickAddViewController : QuickAddViewController?
    var storedTabBarController : StoredTabBarController?
    override func viewDidLoad() {
        super.viewDidLoad()
        findQuickAddViewController()
    }
    
    private func findQuickAddViewController() {
        print(viewControllers[0])
        guard let lastViewController = viewControllers.first as? QuickAddViewController else {
            return // No ExpiringViewController found
        }
        quickAddViewController = lastViewController
        lastViewController.quickAddNavigationController = self
    }

}
