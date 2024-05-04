import UIKit

protocol CustomAlertDismissalDelegate: AnyObject {
    func alertDismissed()
}

protocol CustomAlertRefreshDelegate: AnyObject {
    func finishedAddingItem()
}

class CustomAlertController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var cameraDelegate: CustomAlertDismissalDelegate?
    var inventoryStorageTableDelegate: CustomAlertRefreshDelegate?
    var inventoryCollectionDelegate: CustomAlertRefreshDelegate?
    var expiringDelegate : CustomAlertRefreshDelegate?
    
    var productTitle: String?
    var productImageUrl: String?
    let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
    
    // MARK: - Outlets
    
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var quantityStepper: UIStepper!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var buttonStack: UIStackView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    // MARK: - Actions
    
    @IBAction private func stepperTapped(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        quantityLabel.text = "\(newValue)"
    }
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        handleAddButtonTapped()
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        cameraDelegate?.alertDismissed()
        
    }
    
    @IBAction private func datePickerValueChanged() {
        handleDatePickerValueChanged()
    }
    
    // MARK: - Private Functions
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertView.layer.cornerRadius = 20
        pickerView.dataSource = self
        pickerView.delegate = self
        titleTextField.delegate = self
        if let productTitle = productTitle {
            titleTextField.text = productTitle
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
        let color = buttonStack.backgroundColor
        
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color?.cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: buttonStack.frame.width, height: 1)
        buttonStack.layer.addSublayer(borderLayer)
        
        if let productImageUrl = productImageUrl, let url = URL(string :productImageUrl) {
            ItemData.getInstance().loadImageFrom(url: url){ image in
                if let image = image {
                    self.itemImageView.image = image
                } else {
                    print("Failed to load image")
                }
            }
        }
        itemImageView.layer.cornerRadius = 20
        datePicker.minimumDate = Date()
    }
    
    @objc private func handleImageTap() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                } else {
                    print("Camera is not available.")
                }
            }
            alertController.addAction(takePhotoAction)
            
            let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            alertController.addAction(chooseFromLibraryAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        // UIImagePickerControllerDelegate methods
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                itemImageView.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                itemImageView.image = originalImage
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    
    private func handleAddButtonTapped() {
        
        
        guard titleTextField.text != "" else { return }
        guard (itemImageView.image?.isSymbolImage) == false else {
            print("Image Not found")
            return}
        let itemImage = itemImageView.image!
        let itemName = titleTextField.text!
        let itemQuantity = Int(quantityLabel.text ?? "0") ?? 1
        let itemExpiryDate = datePicker.date
        let selectedStorageIndex = pickerView.selectedRow(inComponent: 0)
        let itemStorage = storageLocations[selectedStorageIndex]
        
        if let url = productImageUrl {
            let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, expiryDate: itemExpiryDate, imageUrl: url, image: itemImage)
            addItemToStorage(newItem, at: selectedStorageIndex)
        }else {
            let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, expiryDate: itemExpiryDate, image: itemImage)
            addItemToStorage(newItem, at: selectedStorageIndex)
        }
        
    }
    
    func isSystemPhotoImage(_ image: UIImage?) -> Bool {
        let systemImageName = "photo"
        guard let image = image else { return false }
        print("image is herer")
        // Extract the system name from the image's description
        let imageName = image.description.components(separatedBy: " ").last ?? ""
        print(image.isSymbolImage)
        // Compare against the known system image name
        return imageName == systemImageName
    }


    
    private func addItemToStorage(_ item: Item, at index: Int) {
        let storage = StorageData.getInstance().storages[index]
        storage.items.append(item)
        
        if let inventoryStorageTableDelegate = inventoryStorageTableDelegate {
            inventoryStorageTableDelegate.finishedAddingItem()
        }
        if let inventoryCollectionDelegate = inventoryCollectionDelegate {
            inventoryCollectionDelegate.finishedAddingItem()
        }
        dismiss(animated: true){
            let alertController = UIAlertController(title: "\(item.name) Added", message: "\(item.name) x\(item.quantity) has been added to your \(item.storage)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self.cameraDelegate?.alertDismissed()
            }
            
            alertController.addAction(action)
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = scene.windows.first {
                    if let topViewController = window.rootViewController {
                        var currentViewController = topViewController
                    
                        while let presentedViewController = currentViewController.presentedViewController {
                            currentViewController = presentedViewController
                        }
                        
                        currentViewController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func handleDatePickerValueChanged() {
        dismiss(animated: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
}

// MARK: - UIPickerViewDataSource

extension CustomAlertController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return storageLocations.count
    }
}

// MARK: - UIPickerViewDelegate

extension CustomAlertController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return storageLocations[row]
    }
}

// MARK: - UITextFieldDelegate

extension CustomAlertController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
