////
////  InventoryNavigationController.swift
////  Stored
////
////  Created by student on 25/04/24.
////
//
//import UIKit
//import VisionKit
//import AVFoundation
//
//class InventoryNavigationController: UINavigationController {
//    
//    var captureSession : AVCaptureSession!
//    var previewLayer : AVCaptureVideoPreviewLayer!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addScanButton()
//        
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
//                print("Your device is not applicable")
//                return
//            }
//            
//            let videoInput : AVCaptureDeviceInput
//            
//            do {
//                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//            }catch{
//                print("Your device cannot give video input")
//                return
//            }
//            
//            if (self.captureSession.canAddInput(videoInput)){
//                self.captureSession.canAddInput(videoInput)
//            }else {
//                return
//            }
//            
//            let metaDataOutput = AVCaptureMetadataOutput()
//            
//            if (self.captureSession.canAddOutput(metaDataOutput)){
//                self.captureSession.addOutput(metaDataOutput)
//            }else {
//                return
//            }
//            
//            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//            self.previewLayer.frame = self.view.layer.bounds
//            self.previewLayer.videoGravity = .resizeAspectFill
//            
//            self.view.layer.addSublayer(self.previewLayer)
//            print("running")
//            self.captureSession.startRunning()
//        })
//    }
//}
//
//extension UINavigationController : AVCaptureMetadataOutputObjectsDelegate {
//    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if let first = metadataObjects.first{
//            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else {
//                return
//            }
//            guard let stringValue = readableObject.stringValue else {
//                return
//            }
//            found(code: stringValue)
//        }else {
//            print("Not able to read")
//        }
//    }
//    
//    func found (code : String){
//        print(code)
//    }
//}
//extension UINavigationController : DataScannerViewControllerDelegate {
//    
//    var isScannerAvailable : Bool {
//        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
//    }
//    func addScanButton () {
//        
//        if view.viewWithTag(999) != nil {
//            // Button already exists, no need to add it again
//            return
//        }
//        
//        
//        let scanButton: ScanItemButton = {
//            let button = ScanItemButton(type: .system)
////          button.setTitle("ScanButton", for: .normal)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.tag = 999
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//            return button
//        }()
//        
//        scanButton.setupUI(in: view)
//    }
//    
//    @objc func buttonTapped(_ sender: UIButton) {
//        // Add your code here to handle the button tap
//        print("Button tapped!")
//        guard isScannerAvailable == true else {
//            print("Scanner is not avalaible")
//            return
//        }
//        
//        let dataScanner = DataScannerViewController(recognizedDataTypes: [.text(), .barcode()], isHighlightingEnabled: true)
//        dataScanner.delegate = self
//        present(dataScanner, animated: true)
//        try? dataScanner.startScanning()
//        
//    }
//}
//
//extension InventoryViewController : DataScannerViewControllerDelegate {
//    
//    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//            print("Data tapped")
//            
//            switch item {
//            case .text(let text):
//                print("Text: \(text.transcript)")
//                UIPasteboard.general.string = text.transcript
//            case .barcode(let code):
//                guard let urlString = code.payloadStringValue else { return }
//                guard let url = URL(string: urlString) else { return }
//                print("Barcode: \(code)")
//                
//                let alertController = UIAlertController(title: "Barcode Detected", message: "Barcode: \(code)", preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                DispatchQueue.main.async {
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            default:
//                print("Item not recognized")
//            }
//        }
//}


//import UIKit
//import AVFoundation
//
//class InventoryNavigationController: UINavigationController, AVCaptureMetadataOutputObjectsDelegate {
//    
//    var captureSession: AVCaptureSession!
//    var previewLayer: AVCaptureVideoPreviewLayer!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addScanButton()
//    }
//    
//    func setupCaptureSession() {
//        captureSession = AVCaptureSession()
//        
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
//            print("Your device is not applicable")
//            return
//        }
//        
//        let videoInput: AVCaptureDeviceInput
//        
//        do {
//            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//        } catch {
//            print("Your device cannot give video input")
//            return
//        }
//        
//        if captureSession.canAddInput(videoInput) {
//            captureSession.addInput(videoInput)
//        } else {
//            print("Could not add video input to capture session")
//            return
//        }
//        
//        let metaDataOutput = AVCaptureMetadataOutput()
//        
//        if captureSession.canAddOutput(metaDataOutput) {
//            captureSession.addOutput(metaDataOutput)
//            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            metaDataOutput.metadataObjectTypes = [.ean13, .qr]
//        } else {
//            print("Could not add metadata output to capture session")
//            return
//        }
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.layer.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        
//        view.layer.addSublayer(previewLayer)
//        
//        captureSession.startRunning()
//    }
//    
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if let first = metadataObjects.first,
//           let readableObject = first as? AVMetadataMachineReadableCodeObject,
//           let stringValue = readableObject.stringValue {
//            found(code: stringValue)
//        } else {
//            print("Not able to read")
//        }
//    }
//    
//    func found(code: String) {
//        print(code)
//        
//        // Construct the API URL
//        let apiString = "https://world.openfoodfacts.net/api/v2/product/\(code)"
//        guard let url = URL(string: apiString) else {
//            print("Invalid API URL")
//            return
//        }
//        
//        // Create a URLSession
//        let session = URLSession.shared
//        
//        // Create a data task to make the network request
//        let task = session.dataTask(with: url) { data, response, error in
//            // Check for errors
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            
//            // Check if data is received
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            do {
//                // Parse JSON data
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                
//                // Extract product name from JSON
//                if let product = json?["product"] as? [String: Any],
//                   let productName = product["product_name"] as? String {
//                    print("Product Name: \(productName)")
//                    
//                    // Present the product name in an alert
//                    DispatchQueue.main.async {
//                        if let cameraViewController = self.presentedViewController {
////                            let alertController = UIAlertController(title: "Barcode Detected", message: "Product Name: \(productName)", preferredStyle: .alert)
////                            
////                            // Add a date picker as input view for the date text field
////                            let datePicker = UIDatePicker()
////                            datePicker.datePickerMode = .date
////                            let dateFormatter = DateFormatter()
////                            dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust the date format as needed
////                                                   
////                            
////                            let textField = UITextField()
////                            textField.placeholder = "Select Date"
////                            textField.inputView = datePicker // Set the date picker as the input view
////                            textField.text = dateFormatter.string(from: datePicker.date) // Set initial text
////
////                            // Add the text field to the alert controller's view
////                            alertController.view.addSubview(textField)
////                            
////                            alertController.addTextField { textField in
////                                textField.placeholder = "Enter Quantity"
////                                textField.keyboardType = .numberPad // Set keyboard type to number pad
////                                // You can customize the text field properties here
////                            }
////                            
//                            
//                            
//                            // Add action for "OK" button
////                            let okAction = UIAlertAction(title: "OK", style: .default) 
////                            { _ in
//                                // Retrieve values from text fields
////                                if let dateText = alertController.textFields?[0].text,
////                                   let quantityText = alertController.textFields?[1].text,
////                                   let quantity = Int(quantityText) {
////                                    print("Date: \(dateText), Quantity: \(quantity)")
////                                    // You can use the date and quantity values here
////                                    
////                                    // Convert the date text to a Date object
////                                    let dateFormatter = DateFormatter()
////                                    dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust the date format as needed
////                                    if let date = dateFormatter.date(from: dateText) {
////                                        print("Date Object: \(date)")
////                                    }
////                                }
////                            }
////                            alertController.addAction(okAction)
////                        
////                            // Add action for "Cancel" button
////                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
////                            alertController.addAction(cancelAction)
////                            
////                            cameraViewController.present(alertController, animated: true, completion: nil)
////                            
//                            if let presentedViewController = cameraViewController.presentedViewController {
//                                // Create an instance of CustomAlertController
//                                let alertActions: [UIAlertAction] = [
//                                    UIAlertAction(title: "OK", style: .default, handler: nil),
//                                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                                ]
//                                let customAlertController = CustomAlertController(title: "Barcode Detected", message: "Product Name: \(productName)", actions: alertActions)
//                                
//                                // Present the CustomAlertController on the currently presented view controller
//                                presentedViewController.present(customAlertController, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                } else {
//                    print("Product name not found in response")
//                }
//            } catch {
//                print("Error parsing JSON: \(error)")
//            }
//        }
//        
//        // Start the data task
//        task.resume()
//    }
//
//    
//    
//        func addScanButton () {
//    
//            if view.viewWithTag(999) != nil {
//                // Button already exists, no need to add it again
//                return
//            }
//    
//    
//            let scanButton: ScanItemButton = {
//                let button = ScanItemButton(type: .system)
//    //          button.setTitle("ScanButton", for: .normal)
//                button.translatesAutoresizingMaskIntoConstraints = false
//                button.tag = 999
//                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//                return button
//            }()
//    
//            scanButton.setupUI(in: view)
//        }
//    
//    @objc func buttonTapped(_ sender: UIButton) {
//        print("Button tapped!")
//        setupCaptureSession()
//        presentCameraViewModally()
//    }
//    
//    func presentCameraViewModally() {
//        let cameraViewController = UIViewController()
//        cameraViewController.view.backgroundColor = .clear // Optionally, set a transparent background
//            
//        // Set the frame of the preview layer to fit the screen
//        previewLayer.frame = cameraViewController.view.layer.bounds
//        cameraViewController.view.layer.addSublayer(previewLayer)
//        present(cameraViewController, animated: true, completion: nil)
//    }
//}


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
