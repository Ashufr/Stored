import UIKit

protocol CustomAlertDelegate{
    func alertDismissed()
}

class CustomAlertController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var cameraDelegate : CustomAlertDelegate?
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var addButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
    
    var productTitle : String?
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        print("diididd")
        cameraDelegate?.alertDismissed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        titleTextField.delegate = self
        if let productTitle = productTitle {
            titleTextField.text = productTitle
        }
        
        print("View")
//        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
//        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    
    @objc private func closeButtonTapped() {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func stepperTapped(_ sender: UIStepper, forEvent event: UIEvent) {
        let newValue = Int(sender.value)
        quantityLabel.text = "\(newValue)"
        
        
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
        guard let itemName = titleTextField.text else {return}
        let itemQuantity = Int(quantityLabel.text ?? "0") ?? 1
    
        let itemExpiryDate = datePicker.date
        
        let selectedStorageIndex = pickerView.selectedRow(inComponent: 0)
        let itemStorage = storageLocations[selectedStorageIndex]
        
        let newItem = Item(name: itemName, quantity: itemQuantity, storage: itemStorage, expiryDate: itemExpiryDate)
        
        switch itemStorage {
        case "Pantry":
            StorageData.getInstance().storages[0].items.append(newItem)
        case "Fridge":
            StorageData.getInstance().storages[1].items.append(newItem)
        case "Freezer":
            StorageData.getInstance().storages[2].items.append(newItem)
        case "Shelf":
            StorageData.getInstance().storages[3].items.append(newItem)
        default:
            break
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerValueChanged() {
        dismiss(animated: true, completion: nil)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return storageLocations.count
       }
       
       // MARK: - UIPickerViewDelegate
       
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return storageLocations[row]
       }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

}

