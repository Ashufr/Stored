import UIKit

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    var parentNavigationController: InventoryNavigationController?
    
    // MARK: - View Lifecycle
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parentNavigationController?.captureSession?.stopRunning()
    }
}
