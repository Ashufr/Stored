import UIKit
import AVFoundation

class InventoryNavigationController: UINavigationController, AVCaptureMetadataOutputObjectsDelegate, CustomAlertDismissalDelegate {
    
    // MARK: - Properties
    
    private var cameraViewController: CameraViewController?
    private var backgroundView: UIView?
    private var loadingIndicator: UIActivityIndicatorView?
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScanButton()
    }
    
    // MARK: - Button Actions
    
    private func addScanButton() {
        guard view.viewWithTag(999) == nil else { return }
        
        let scanButton = ScanItemButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.tag = 999
        scanButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        scanButton.setupUI(in: view)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button tapped!")
        presentCameraViewController()
    }
    
    // MARK: - Camera Handling
    
    private func presentCameraViewController() {
        cameraViewController = CameraViewController()
        guard let cameraViewController = cameraViewController else { return }
        
        cameraViewController.parentNavigationController = self
        cameraViewController.modalPresentationStyle = .popover
        
        setupCaptureSession()
        setupBackButton(on: cameraViewController.view)
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
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
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = cameraViewController!.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraViewController!.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    // MARK: - Back Button
    
    private func setupBackButton(on view: UIView) {
        let backButton = UIButton(type: .system)
        backButton.backgroundColor = .white
        let backImage = UIImage(systemName: "chevron.left")
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .black // Adjust the color as needed
        backButton.layer.cornerRadius = 8 // Adjust corner radius as needed
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first,
           let readableObject = first as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            captureSession!.stopRunning()
            
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            guard let backgroundView = backgroundView else { return }
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            backgroundView.layer.cornerRadius = 10
            
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator?.startAnimating()
            loadingIndicator?.center = CGPoint(x: backgroundView.bounds.midX, y: backgroundView.bounds.midY)
            backgroundView.addSubview(loadingIndicator!)
            
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
    
    // MARK: - CustomAlertController
    
    func displayCustomAlert(productNameString: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Unable to find window scene")
            return
        }
        
        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        guard let customAlertController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomAlertVC") as? CustomAlertController else {
            return
        }
        
        if let topViewController = self.topViewController {
            if let inventoryViewController = topViewController as? InventoryViewController {
                customAlertController.inventoryCollectionDelegate = inventoryViewController
                customAlertController.inventoryStorageTableDelegate = inventoryViewController.inventoryStorageViewController
                
            } else if let inventoryStorageController = topViewController as? InventoryStorageViewController {
                customAlertController.inventoryCollectionDelegate = inventoryStorageController.inventoryViewController
                customAlertController.inventoryStorageTableDelegate = inventoryStorageController
            }
        }
        
        customAlertController.productTitle = productNameString
        customAlertController.cameraDelegate = self
        
        customAlertController.modalPresentationStyle = .overFullScreen
        customAlertController.modalTransitionStyle = .crossDissolve
        
        topViewController?.present(customAlertController, animated: true) {
            self.loadingIndicator?.stopAnimating()
            self.loadingIndicator?.removeFromSuperview()
            
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
        let apiString = "https://world.openfoodfacts.net/api/v2/product/\(code)"
        guard let url = URL(string: apiString) else {
            print("Invalid API URL")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let product = json?["product"] as? [String: Any],
                   let productName = product["product_name"] as? String {
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
    
    // MARK: - CustomAlertDismissalDelegate
    
    func alertDismissed() {
        print("dismissde")
        captureSession?.startRunning()
    }
}
