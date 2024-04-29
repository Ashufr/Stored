import UIKit
import AVFoundation

class InventoryNavigationController: UINavigationController, AVCaptureMetadataOutputObjectsDelegate, CustomAlertDismissalDelegate {
    func alertDismissed() {
        captureSession?.startRunning()
    }
    
    
    private var cameraViewController: CameraViewController?
    
    var backgroundView : UIView?
    var loadingIndicator : UIActivityIndicatorView?
    
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScanButton()
        //        setupCaptureSession()
    }
    func addScanButton() {
        if view.viewWithTag(999) != nil {
            // Button already exists, no need to add it again
            return
        }
        
        let scanButton: ScanItemButton = {
            let button = ScanItemButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = 999
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            return button
        }()
        
        scanButton.setupUI(in: view)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("Button tapped!")
        presentCameraViewController()
    }
    
    
    
    func presentCameraViewController() {
        
        cameraViewController = CameraViewController()
        guard let cameraViewController = cameraViewController else {return}
        cameraViewController.parentNavigationController = self
        cameraViewController.modalPresentationStyle = .popover
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {return}
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to access camera")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input to capture session")
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean13, .qr]
        } else {
            print("Could not add metadata output to capture session")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else {return}
        previewLayer.frame = cameraViewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraViewController.view.layer.addSublayer(previewLayer)

        
        let backButton = UIButton(type: .system)
        backButton.backgroundColor = .white
        let backImage = UIImage(systemName: "chevron.left")
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .black // Adjust the color as needed
        backButton.layer.cornerRadius = 8 // Adjust corner radius as needed
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        cameraViewController.view.addSubview(backButton)

        // Constraints for the back button
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: cameraViewController.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: cameraViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        view.bringSubviewToFront(backButton)
        
        captureSession.startRunning()
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
            // Dismiss the camera view controller
            dismiss(animated: true, completion: nil)
        }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first,
           let readableObject = first as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            captureSession!.stopRunning()
            
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            guard let backgroundView = backgroundView else {return}
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            backgroundView.layer.cornerRadius = 10
            
            // Initialize the loading indicator
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator?.startAnimating()
            
            // Center the loading indicator within the background view
            loadingIndicator?.center = CGPoint(x: backgroundView.bounds.midX, y: backgroundView.bounds.midY)
            
            // Add the loading indicator to the background view
            backgroundView.addSubview(loadingIndicator!)
            
            // Add the background view to the top window
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topWindow = scene.windows.first {
                backgroundView.center = topWindow.center
                topWindow.addSubview(backgroundView)
            }
            found(code: stringValue)
        } else {
            print("Not able to read")
        }
    }
    
        
    func displayCustomAlert(productNameString : String) {
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Unable to find window scene")
            return
        }
        
        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let customAlertController = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as? CustomAlertController else {
            return
        }
        
        if let topViewController = self.topViewController {
            if let inventoryViewController = topViewController as? InventoryViewController {
                customAlertController.inventoryCollectionDelegate = inventoryViewController
                customAlertController.inventoryStorageTableDelegate = inventoryViewController.inventoryStorageViewController
               
            }else if let inventoryStorageController = topViewController as? InventoryStorageViewController{
                print("Found Storage")
                customAlertController.inventoryCollectionDelegate = inventoryStorageController.inventoryViewController
                customAlertController.inventoryStorageTableDelegate = inventoryStorageController
            }
        }
        customAlertController.productTitle = productNameString
        customAlertController.cameraDelegate = self
        
        
        // Configure custom animation for the presentation
        customAlertController.modalPresentationStyle = .overFullScreen
        customAlertController.modalTransitionStyle = .crossDissolve // or any other transition style you prefer
        
        // Present the CustomAlertController modally with animation
        topViewController?.present(customAlertController, animated: true){
            self.loadingIndicator!.stopAnimating()
            self.loadingIndicator!.removeFromSuperview()
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topWindow = scene.windows.first {
                for subview in topWindow.subviews {
                    if subview.backgroundColor == UIColor.white.withAlphaComponent(0.9) {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func found(code: String) {
        print(code)
        
        // Construct the API URL
        let apiString = "https://world.openfoodfacts.net/api/v2/product/\(code)"
        guard let url = URL(string: apiString) else {
            print("Invalid API URL")
            return
        }
        
        // Create a URLSession
        let session = URLSession.shared
        
        // Create a data task to make the network request
        let task = session.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if data is received
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Parse JSON data
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                // Extract product name from JSON
                if let product = json?["product"] as? [String: Any],
                   let productName = product["product_name"] as? String {
                    print("Product Name: \(productName)")
                    
                    // Present the product name in an alert
                    DispatchQueue.main.async {
                        self.displayCustomAlert(productNameString: productName)
                    }
                } else {
                    print("Product name not found in response")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
}

