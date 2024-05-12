import UIKit
import FirebaseAuth

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
    var inventoryNavigationController :InventoryNavigationController?
    
    var productTitle: String?
    var productImageUrl: String?
    var productImage : UIImage?
    let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
    var productQuanity : Int?
    var productExpiry : Date?
    var productStorageIndex : Int?
    var productDateAdded : Date?
    var isUpdating : Bool = false
    var itemId : String?
    var oldStorage : String?
    
    // MARK: - Outlets
    
    @IBOutlet var alertView: UIView!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var buttonStack: UIStackView!
    
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
        if let productImage = productImage {
            itemImageView.image = productImage
        }
        if let productImageUrl = productImageUrl, let url = URL(string :productImageUrl) {
            ItemData.getInstance().loadImageFrom(url: url){ image in
                if let image = image {
                    self.itemImageView.image = image
                } else {
                    print("Failed to load image")
                }
            }
        }
        if let productQuanity = productQuanity {
            quantityStepper.value = Double(productQuanity)
            quantityLabel.text = "\(productQuanity)"
        }
        if let productExpiry = productExpiry {
            datePicker.date = productExpiry
        }
        
        if let productStorageIndex = productStorageIndex {
            pickerView.selectRow(productStorageIndex, inComponent: 0, animated: true)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
        let color = buttonStack.backgroundColor
        
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color?.cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: buttonStack.frame.width, height: 1)
        buttonStack.layer.addSublayer(borderLayer)
        
        if isUpdating{
            self.addButton.setTitle("Save", for: .normal)
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
        productStorageIndex = selectedStorageIndex
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            print("email not found")
            return
        }
        let safeEmail = StorageManager.safeEmail(email: email)
        
//        if let url = productImageUrl {
//            let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, dateAdded : productDateAdded ?? Date(), expiryDate: itemExpiryDate, imageURL: url, image: itemImage, userId: safeEmail)
//            addItemToStorage(newItem, at: selectedStorageIndex)
//        }else {
//            
//            let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, dateAdded : productDateAdded ?? Date(), expiryDate: itemExpiryDate, image: itemImage, userId: safeEmail)
//            addItemToStorage(newItem, at: selectedStorageIndex)
//        }
        
        let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, dateAdded : productDateAdded ?? Date(), expiryDate: itemExpiryDate, imageURL: productImageUrl, image: itemImage, userId: safeEmail)
        addItemToStorage(newItem, at: selectedStorageIndex)
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
        guard let houseHoldcode = UserData.getInstance().user?.household?.code else {
            print("House code not found")
            return
        }
        
        if isUpdating {
            item.itemId = self.itemId
            DatabaseManager.shared.updateItem(householdCode: houseHoldcode,oldStorageName: self.oldStorage!, for: item){error in
                if error == nil {
                    self.displayUpadtedAlert(item: item)
                }
            }
        }else{
            DatabaseManager.shared.insertItem(with: item, householdCode: houseHoldcode, storageName: item.storage) { [weak self] itemRef in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    if let itemRef = itemRef {
                        strongSelf.handleSuccess(for: item)
                        
                        if item.imageURL == nil || item.imageURL?.absoluteString == ""{
                            let fileName = itemRef
                            StorageManager.shared.uploadItemImage(with: strongSelf.itemImageView.image!, fileName: fileName) { result in
                                switch result {
                                case .success(let downloadURL):
                                    print("Item image uploaded successfully. Download URL: \(downloadURL) nn")
                                    DatabaseManager.shared.updateItemImageURL(householdCode: houseHoldcode, storageName: item.storage, forItemWithID: itemRef, imageURL: downloadURL){error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        }
                                    }
                                case .failure(let error):
                                    print("Error uploading item image: \(error)")
                                    // Handle error
                                }
                            }
                        }
                    } else {
                        strongSelf.handleError(for: item)
                    }
                }
            }
        }
    }
    
    private func handleSuccess(for item: Item) {
        if let inventoryStorageTableDelegate = inventoryStorageTableDelegate {
            inventoryStorageTableDelegate.finishedAddingItem()
        }
        if let inventoryCollectionDelegate = inventoryCollectionDelegate {
            inventoryCollectionDelegate.finishedAddingItem()
        }
        if isUpdating {
            displayUpadtedAlert(item: item)
        }else{
            displayAddedAlert(item: item)
        }
        
    }
    
    private func handleError(for item: Item) {
        let alertController = UIAlertController(title: "Error adding item", message: "\(item.name) x\(item.quantity) was not added to your \(item.storage)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.cameraDelegate?.alertDismissed()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func handleDatePickerValueChanged() {
        dismiss(animated: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
    
    func displayAddedAlert(item : Item){
        dismiss(animated: true) {
            let alertController = UIAlertController(title: "\(item.name) added", message: "\(item.name) x\(item.quantity) has been added to your \(item.storage)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self.cameraDelegate?.alertDismissed()
            }
            alertController.addAction(action)
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
    }
    
    func displayUpadtedAlert(item : Item){
        dismiss(animated: true) {
            let alertController = UIAlertController(title: "\(item.name) Updated", message: "\(item.name) has been updated", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self.cameraDelegate?.alertDismissed()
            }
            alertController.addAction(action)
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
