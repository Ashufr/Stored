import UIKit
import AVFoundation

class InventoryNavigationController: UINavigationController, AVCaptureMetadataOutputObjectsDelegate, CustomAlertDismissalDelegate {
    func alertDismissed() {
        captureSession?.startRunning()
    }
    
    
    private var cameraViewController: UIViewController?
    
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
        let cameraViewController = UIViewController()
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
        
        captureSession.startRunning()
        
        present(cameraViewController, animated: true, completion: nil)
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
            // Step 2: Check if the top view controller is of type InventoryViewController
            if let inventoryViewController = topViewController as? InventoryViewController {
                customAlertController.inventoryCollectionDelegate = inventoryViewController
                // Step 3: Access the embedded InventoryStorageViewController
                if let inventoryStorageViewController = inventoryViewController.children.first(where: { $0 is InventoryStorageViewController }) as? InventoryStorageViewController {
                    // Now you have access to the InventoryStorageViewController
                    print("Found InventoryStorageViewController: \(inventoryStorageViewController)")
                } else {
                    print("InventoryStorageViewController not found")
                }
            } else {
                print("Top view controller is not of type InventoryViewController")
            }
        } else {
            print("No view controller in the navigation stack")
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
        
        // Start the data task
        task.resume()
    }
}

