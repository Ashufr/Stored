

import UIKit


class CameraViewController : UIViewController{
    var parentNavigationController : InventoryNavigationController?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parentNavigationController!.captureSession!.stopRunning()
    }

}

