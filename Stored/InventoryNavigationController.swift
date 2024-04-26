import UIKit
import AVFoundation

class InventoryNavigationController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScanButton()
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
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }
}

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Your device is not applicable")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Your device cannot give video input")
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
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first,
           let readableObject = first as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            found(code: stringValue)
        } else {
            print("Not able to read")
        }
    }
    
    func displayCustomAlert(productNameString : String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let customAlertController = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as? CustomAlertController else {
            return
        }
        
        customAlertController.productTitle = productNameString
        
        // Configure custom animation for the presentation
        customAlertController.modalPresentationStyle = .overFullScreen
        customAlertController.modalTransitionStyle = .crossDissolve // or any other transition style you prefer
        
        // Present the CustomAlertController modally with animation
        present(customAlertController, animated: true, completion: nil)
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
//
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
