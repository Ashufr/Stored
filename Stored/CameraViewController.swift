import UIKit

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    var parentNavigationController: InventoryNavigationController?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parentNavigationController?.captureSession?.stopRunning()
    }
    
    // MARK: - Gesture Setup
    
    private func setupGestures() {
        // Zoom Gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        // Focus Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Actions
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let parentNavigationController = parentNavigationController else { return }
        let zoomFactor: CGFloat = gesture.scale * 1.5 // Adjust the scale factor as needed
        parentNavigationController.zoomCamera(to: zoomFactor)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let parentNavigationController = parentNavigationController else { return }
        let tapPoint = gesture.location(in: view)
        let convertedPoint = CGPoint(x: tapPoint.x / view.bounds.size.width, y: tapPoint.y / view.bounds.size.height)
        parentNavigationController.focusCamera(at: convertedPoint)
    }
    
}


//topViewController?.present(customAlertController, animated: true) {
//    self.loadingIndicator?.stopAnimating()
//    self.loadingIndicator?.removeFromSuperview()
//    
//    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//       let topWindow = scene.windows.first {
//        for subview in topWindow.subviews {
//            if subview.backgroundColor == UIColor.white.withAlphaComponent(0.9) {
//                subview.removeFromSuperview()
//            }
//        }
//    }
//}
