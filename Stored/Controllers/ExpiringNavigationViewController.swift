
import UIKit

class ExpiringNavigationViewController: UINavigationController {

    var expiringViewController: ExpiringViewController?
    var storedTabBarController : StoredTabBarController?
    override func viewDidLoad() {
        super.viewDidLoad()
        findExpiringViewController()
    }
    
    private func findExpiringViewController() {
        guard let lastViewController = viewControllers.last as? ExpiringViewController else {
            return // No ExpiringViewController found
        }
        expiringViewController = lastViewController
        lastViewController.expiringNavigationController = self
        
    }
}
