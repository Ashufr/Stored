import UIKit
import Vision
import AVFoundation

class InventoryNavigationController: UINavigationController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    var cameraViewController: CameraViewController?
    var billViewController : BillViewController?
    var inventoryViewController : InventoryViewController?
    var storedTabBarController : StoredTabBarController?
    var backgroundView: UIView?
    var loadingIndicator: UIActivityIndicatorView?
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput : AVCapturePhotoOutput?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScanButton()
        addBillScanButton()
        findInventoryViewController()
    }
    
    // MARK: - Setting Inventory View Controler
    
    private func findInventoryViewController() {
        print("Hellooooodosodfo")
        guard let lastViewController = viewControllers.last as? InventoryViewController else {
            return // No ExpiringViewController found
        }
        inventoryViewController = lastViewController
        lastViewController.inventoryNavigationController = self
        print("Found inventory")
    }
    
    // MARK: - Button Actions
    
    private func addScanButton() {
        guard view.viewWithTag(999) == nil else { return }
        
        let scanButton = ScanItemButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.tag = 999
        scanButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        scanButton.setupUI(in: view)
        
//        guard view.viewWithTag(998) == nil else { return }
//        
//        let billButton = ScanItemButton(type: .system)
//        billButton.translatesAutoresizingMaskIntoConstraints = false
//        billButton.tag = 998
//        billButton.addTarget(self, action: #selector(billButtonTapped(_:)), for: .touchUpInside)
//        billButton.setupUI(in: view)
    }
    
    private func addBillScanButton() {
        guard view.viewWithTag(998) == nil else { return }
        
        let billButton = BillButton(type: .system)
        billButton.translatesAutoresizingMaskIntoConstraints = false
        billButton.tag = 998
        billButton.addTarget(self, action: #selector(billButtonTapped(_:)), for: .touchUpInside)
        billButton.setupUI(in: view)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button tapped!")
        presentCameraViewController()
//        presentBillViewController()
    }
    
    @objc private func billButtonTapped(_ sender: UIButton) {
        print("Bill Button tapped!")
//        presentCameraViewController()
        presentBillViewController()
    }
    // MARK: - Camera Handling
    
    private func presentBillViewController() {
//        cameraViewController = CameraViewController()
        billViewController = BillViewController()
        guard let billViewController = billViewController else { return }
        
        billViewController.parentNavigationController = self
        billViewController.modalPresentationStyle = .popover
        
        setupBillCaptureSession()
        setupCaptureButton(on : billViewController.view)
        setupBackButton(on: billViewController.view)
//        setupManualyAddButton(on: billViewController.view)
        setupRectangularFrame(on: billViewController.view)
        
        present(billViewController, animated: true, completion: nil)
    }
    
    private func presentCameraViewController() {
        cameraViewController = CameraViewController()
//        cameraViewController = BillViewController()
        guard let cameraViewController = cameraViewController else { return }
        
        cameraViewController.parentNavigationController = self
        cameraViewController.modalPresentationStyle = .popover
        
        setupCaptureSession()
//        setupCaptureButton(on : cameraViewController.view)
        setupBackButton(on: cameraViewController.view)
        setupManualyAddButton(on: cameraViewController.view)
        setupRectangularFrame(on: cameraViewController.view)
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    
    
    private func setupBillCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        
        do {
            guard let camera = AVCaptureDevice.default(for: .video) else {return}
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
            
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput {
                captureSession.addOutput(photoOutput)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            guard let previewLayer = previewLayer else { return }
            previewLayer.frame = billViewController!.view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            billViewController!.view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        } catch {
            print("Error setting up capture session: \(error.localizedDescription)")
        }
        
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
//
        
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
    
    private func setupCaptureButton(on view : UIView) {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Scan Bill", for: .normal)
//        captureButton.layer.frame = CGRect(x: 0, y: 0, width: 90, height: 20)
        captureButton.tintColor = UIColor.black
        captureButton.layer.backgroundColor = UIColor.white.cgColor
        captureButton.layer.cornerRadius = 10
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120), // Align vertically with the center
            captureButton.widthAnchor.constraint(equalToConstant: 200), // Adjust width as needed
            captureButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func captureButtonTapped() {
        
        guard let photoOutput = photoOutput else {
            print("No photo output available")
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        guard let capturedImage = cameraViewController?.captureImage() else {
            print("Failed to capture image")
            return
        }
        
        
//        extractText(from: capturedImage)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to capture photo")
            return
        }
        
        let capturedImage = UIImage(data: imageData)!
        captureSession?.stopRunning()
        //            showCapturedImage(capturedImage!)
        extractText(from: capturedImage)
    }
    
    private func showCapturedImage(_ image: UIImage) {
        // Create a new view controller to display the captured image
        let imageViewController = UIViewController()
        imageViewController.view.backgroundColor = .black // Set background color as needed
        
        // Create a UIImageView to display the captured image
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the image view to the imageViewController's view
        imageViewController.view.addSubview(imageView)
        
        // Add constraints to center the image view in the imageViewController's view
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: imageViewController.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageViewController.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: imageViewController.view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageViewController.view.heightAnchor)
        ])
        
        // Present the imageViewController
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Unable to find window scene")
            return
        }
        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        topViewController?.present(imageViewController, animated: true, completion: nil)
    }

    
    private func extractText(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Failed to convert UIImage to CIImage")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                detectedText += topCandidate.string + "\n"
            }
            
            DispatchQueue.main.async {
                self.displayExtractedText(detectedText)
            }
        }
        
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR request failed with error: \(error)")
        }
    }

    private func displayExtractedText(_ text: String) {
        let string = "BELL PEPPER\n CILANTRO\n CHAR\n RED ONION\n BROC CROWNS\n ORG CELERY\n BULK PEARS\n CILANTRO\n"
        let alertController = UIAlertController(title: "Extracted Text", message: string, preferredStyle: .alert)
//        print(text)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.captureSession?.startRunning()
        }
        alertController.addAction(okAction)
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Unable to find window scene")
            return
        }
        
        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        topViewController?.present(alertController, animated: true, completion: nil)
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
    
    // MARK: - Manually Add Button
    
    private func setupManualyAddButton(on view: UIView) {
        let backButton = UIButton(type: .system)
        backButton.backgroundColor = .white
        backButton.setTitle("Add Manually", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Adjust font size as needed
        backButton.setTitleColor(.black, for: .normal) // Adjust color as needed
        backButton.layer.cornerRadius = 8 // Adjust corner radius as needed
        backButton.addTarget(self, action: #selector(manuallyAddButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 110), // Align vertically with the center
            backButton.widthAnchor.constraint(equalToConstant: 250), // Adjust width as needed
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func manuallyAddButtonTapped() {
        captureSession?.stopRunning()
        displayCustomAlert(productNameString: "", productImageUrl: "")
    }
    
    // MARK: - Frame Setup
    
    private func setupRectangularFrame(on view: UIView) {
        let frameLayer = CALayer()
        frameLayer.backgroundColor = UIColor.clear.cgColor // Set background color to clear
        let frameSize = CGSize(width: 320, height: 200) // Adjust frame size as needed
        let frameOrigin = CGPoint(x: view.bounds.midX - frameSize.width / 2, y: view.bounds.midY - frameSize.height / 2 - 50) // Adjust the -50 value to move the frame higher
        frameLayer.frame = CGRect(origin: frameOrigin, size: frameSize)
        
        // Create a mask layer with rounded corners
        let maskLayer = CAShapeLayer()
        maskLayer.frame = frameLayer.bounds
        maskLayer.path = UIBezierPath(roundedRect: frameLayer.bounds, cornerRadius: 50).cgPath // Adjust corner radius as needed
    
        
        // Invert the mask to show border only near the corners
        let invertedMaskLayer = CAShapeLayer()
        invertedMaskLayer.path = maskLayer.path
        invertedMaskLayer.fillColor = UIColor.clear.cgColor
        
        let cornerRadius: CGFloat = 8
        let lineWidth: CGFloat = 3

        // Top-left corner
        let borderLayer1 = CAShapeLayer()
        borderLayer1.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 40), cornerRadius: cornerRadius).cgPath
        borderLayer1.lineWidth = lineWidth
        borderLayer1.strokeColor = UIColor.white.cgColor
        borderLayer1.fillColor = UIColor.clear.cgColor

        // Add curved stroke for top-left corner
        let curvePath1 = UIBezierPath()
        curvePath1.move(to: CGPoint(x: 30, y: 0))
        curvePath1.addQuadCurve(to: CGPoint(x: 0, y: 30), controlPoint: CGPoint(x: 0, y: 0))
        borderLayer1.path = curvePath1.cgPath

        // Top-right corner
        let borderLayer2 = CAShapeLayer()
        borderLayer2.path = UIBezierPath(roundedRect: CGRect(x: frameSize.width - 40, y: 0, width: 40, height: 40), cornerRadius: cornerRadius).cgPath
        borderLayer2.lineWidth = lineWidth
        borderLayer2.strokeColor = UIColor.white.cgColor
        borderLayer2.fillColor = UIColor.clear.cgColor

        // Add curved stroke for top-right corner
        let curvePath2 = UIBezierPath()
        curvePath2.move(to: CGPoint(x: frameSize.width - 30, y: 0))
        curvePath2.addQuadCurve(to: CGPoint(x: frameSize.width, y: 30), controlPoint: CGPoint(x: frameSize.width, y: 0))
        borderLayer2.path = curvePath2.cgPath

        // Bottom-left corner
        let borderLayer3 = CAShapeLayer()
        borderLayer3.path = UIBezierPath(roundedRect: CGRect(x: 0, y: frameSize.height - 40, width: 40, height: 40), cornerRadius: cornerRadius).cgPath
        borderLayer3.lineWidth = lineWidth
        borderLayer3.strokeColor = UIColor.white.cgColor
        borderLayer3.fillColor = UIColor.clear.cgColor

        // Add curved stroke for bottom-left corner
        let curvePath3 = UIBezierPath()
        curvePath3.move(to: CGPoint(x: 0, y: frameSize.height - 30))
        curvePath3.addQuadCurve(to: CGPoint(x: 30, y: frameSize.height), controlPoint: CGPoint(x: 0, y: frameSize.height))
        borderLayer3.path = curvePath3.cgPath

        // Bottom-right corner
        let borderLayer4 = CAShapeLayer()
        borderLayer4.path = UIBezierPath(roundedRect: CGRect(x: frameSize.width - 40, y: frameSize.height - 40, width: 40, height: 40), cornerRadius: cornerRadius).cgPath
        borderLayer4.lineWidth = lineWidth
        borderLayer4.strokeColor = UIColor.white.cgColor
        borderLayer4.fillColor = UIColor.clear.cgColor

        // Add curved stroke for bottom-right corner
        let curvePath4 = UIBezierPath()
        curvePath4.move(to: CGPoint(x: frameSize.width - 30, y: frameSize.height))
        curvePath4.addQuadCurve(to: CGPoint(x: frameSize.width, y: frameSize.height - 30), controlPoint: CGPoint(x: frameSize.width, y: frameSize.height))
        borderLayer4.path = curvePath4.cgPath



        // Add the inverted mask and corner border layers to the frame layer
        frameLayer.addSublayer(invertedMaskLayer)
        frameLayer.addSublayer(borderLayer1)
        frameLayer.addSublayer(borderLayer2)
        frameLayer.addSublayer(borderLayer3)
        frameLayer.addSublayer(borderLayer4)
        
        // Add the frame layer to the view's layer
        view.layer.addSublayer(frameLayer)
    }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension InventoryNavigationController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first,
           let readableObject = first as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            captureSession!.stopRunning()
            
            let tintColor = UIColor(named: "Text Color")!
            let bgColor = UIColor(named: "Background Color")!
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator?.color = tintColor
            loadingIndicator?.startAnimating()
            loadingIndicator?.layer.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            loadingIndicator?.layer.cornerRadius = 10
            loadingIndicator?.layer.backgroundColor = bgColor.withAlphaComponent(0.8).cgColor
            loadingIndicator?.center = view.center

            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topWindow = scene.windows.first {
                topWindow.addSubview(loadingIndicator!)
            }
            found(code: stringValue)
        } else {
            print("Not able to read")
        }
    }
}

// MARK: - CustomAlertDismissalDelegate

extension InventoryNavigationController: CustomAlertDismissalDelegate {
    func alertDismissed() {
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
    }
}

// MARK: - ItemNotFoundAlert

extension InventoryNavigationController {
    func itemNotFoundAlert() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                print("Unable to find window scene")
                return
            }
            
            var topViewController = window.rootViewController
            while let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            }

            let alertController = UIAlertController(title: "Item Not Found", message: "The item was not found.", preferredStyle: .alert)

            let scanAgainAction = UIAlertAction(title: "Scan Again", style: .default) { _ in
                self.captureSession?.startRunning()
            }

            let enterManuallyAction = UIAlertAction(title: "Enter Manually", style: .default) { _ in
                self.displayCustomAlert(productNameString: "", productImageUrl: "")
            }

            alertController.addAction(scanAgainAction)
            alertController.addAction(enterManuallyAction)

           

            // Present the alert on the topmost view controller
            topViewController?.present(alertController, animated: true) {
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
    }
    
    @objc func itemNotFoundAlertDismissed() {
        captureSession?.startRunning()
    }
}

// MARK: - CustomAlertController

extension InventoryNavigationController {
    func displayCustomAlert(productNameString: String, productImageUrl : String) {
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
        if productImageUrl != "" {
            customAlertController.productImageUrl = productImageUrl
        }
        customAlertController.productTitle = productNameString
        customAlertController.cameraDelegate = self
        customAlertController.expiringDelegate = storedTabBarController?.expiringNavigationController?.expiringViewController
        
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
}

// MARK: - API Request

extension InventoryNavigationController {
    func found(code: String) {
        let apiString = "https://world.openfoodfacts.net/api/v3/product/\(code)"
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
                        let imageUrl = product["image_url"] as! String
                    
                    DispatchQueue.main.async {
                        self.displayCustomAlert(productNameString: productName, productImageUrl: imageUrl)
                    }
                } else {
                    self.itemNotFoundAlert()
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
}

// MARK: - Zoom and Focus Functionality

extension InventoryNavigationController {
    // MARK: - Zoom Functionality
    
    func zoomCamera(to zoomFactor: CGFloat) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video capture device found")
            return
        }
        
        do {
            try captureDevice.lockForConfiguration()
            defer { captureDevice.unlockForConfiguration() }
            
            let maxZoomFactor = captureDevice.activeFormat.videoMaxZoomFactor
            let clampedZoomFactor = max(1.0, min(zoomFactor, maxZoomFactor))
            captureDevice.videoZoomFactor = clampedZoomFactor
        } catch {
            print("Failed to lock device for configuration: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Focus Functionality
    
    func focusCamera(at point: CGPoint) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video capture device found")
            return
        }
        
        do {
            try captureDevice.lockForConfiguration()
            defer { captureDevice.unlockForConfiguration() }
            
            if captureDevice.isFocusPointOfInterestSupported {
                captureDevice.focusPointOfInterest = point
            }
            
            if captureDevice.isFocusModeSupported(.autoFocus) {
                captureDevice.focusMode = .autoFocus
            }
        } catch {
            print("Failed to lock device for configuration: \(error.localizedDescription)")
        }
    }
}

