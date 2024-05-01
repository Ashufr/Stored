import UIKit

protocol CustomAlertDismissalDelegate: AnyObject {
    func alertDismissed()
}

protocol CustomAlertRefreshDelegate: AnyObject {
    func finishedAddingItem()
}

class CustomAlertController: UIViewController {
    
    // MARK: - Properties
    
    var cameraDelegate: CustomAlertDismissalDelegate?
    var inventoryStorageTableDelegate: CustomAlertRefreshDelegate?
    var inventoryCollectionDelegate: CustomAlertRefreshDelegate?
    
    var productTitle: String?
    let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var quantityStepper: UIStepper!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
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
        pickerView.dataSource = self
        pickerView.delegate = self
        titleTextField.delegate = self
        if let productTitle = productTitle {
            titleTextField.text = productTitle
        }
    }
    
    private func handleAddButtonTapped() {
        dismiss(animated: true)
        
        guard let itemName = titleTextField.text else { return }
        let itemQuantity = Int(quantityLabel.text ?? "0") ?? 1
        let itemExpiryDate = datePicker.date
        let selectedStorageIndex = pickerView.selectedRow(inComponent: 0)
        let itemStorage = storageLocations[selectedStorageIndex]
        
        let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, expiryDate: itemExpiryDate)
        addItemToStorage(newItem, at: selectedStorageIndex)
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
        if let cameraDelegate = cameraDelegate {
            cameraDelegate.alertDismissed()
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
