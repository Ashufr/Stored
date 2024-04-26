//import UIKit
//
//class CustomAlertController: UIViewController {
//    
//    private let contentView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 12
//        return view
//    }()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private let messageLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    private let stackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.distribution = .fillEqually
//        return stackView
//    }()
//    
//    private var buttons: [UIButton] = []
//    
//    init(title: String, message: String, actions: [UIAlertAction]) {
//        super.init(nibName: nil, bundle: nil)
//        
//        titleLabel.text = title
//        messageLabel.text = message
//        
//        modalPresentationStyle = .overFullScreen
//        transitioningDelegate = self
//        
//        setupViews()
//        setupButtons(actions)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        
//        let containerView = UIView()
//        containerView.addSubview(contentView)
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(messageLabel)
//        containerView.addSubview(stackView)
//        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(containerView)
//        containerView.center = view.center
//        
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
//            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
//            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    private func setupButtons(_ actions: [UIAlertAction]) {
//        for action in actions {
//            let button = UIButton(type: .system)
//            button.setTitle(action.title, for: .normal)
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//            
//            if action.style == .destructive {
//                button.tintColor = .red
//            } else if action.style == .cancel {
//                button.tintColor = .systemBlue
//            }
//            
//            stackView.addArrangedSubview(button)
//            buttons.append(button)
//        }
//    }
//    
//    @objc private func buttonTapped(_ sender: UIButton) {
//        guard let index = buttons.firstIndex(of: sender) else { return }
//        let action = buttons[index].currentTitle!
//        print("Button tapped: \(action)")
//        
//        // Perform the desired action based on the button tapped
//        // ...
//        
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//extension CustomAlertController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}
//
//class CustomPresentationController: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        return containerView?.bounds ?? CGRect.zero
//    }
//    
//    override func dismissalTransitionWillBegin() {
//        presentingViewController.beginAppearanceTransition(false, animated: true)
//    }
//    
//    override func dismissalTransitionDidEnd(_ completed: Bool) {
//        presentingViewController.endAppearanceTransition()
//        if completed {
//            presentingViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//}


//import UIKit
//
//class CustomAlertController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//    }
//
//    private let contentView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 12
//        return view
//    }()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private let messageLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    private let stackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.distribution = .fillEqually
//        return stackView
//    }()
//    
//    private var buttons: [UIButton] = []
//    
//    private let datePicker: UIDatePicker = {
//        let datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .wheels
//        return datePicker
//    }()
//    
//    private let quantityStepper: UIStepper = {
//        let stepper = UIStepper()
//        stepper.minimumValue = 1
//        stepper.maximumValue = 100
//        stepper.value = 1
//        return stepper
//    }()
//    
//    private let quantityLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Quantity: 1"
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private let storageLocationPicker: UIPickerView = {
//        let picker = UIPickerView()
//        return picker
//    }()
//    
//    private let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
//    
//    init(title: String, message: String, actions: [UIAlertAction]) {
//        super.init(nibName: nil, bundle: nil)
//        
//        titleLabel.text = title
//        messageLabel.text = message
//        
//        modalPresentationStyle = .overFullScreen
//        transitioningDelegate = self
//        
//        setupViews()
//        setupButtons(actions)
//        setupDatePicker()
//        setupQuantityStepper()
//        setupStorageLocationPicker()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        let contentSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
//        
//        // Adjust the size of the alert controller
//        preferredContentSize = CGSize(width: contentSize.width + 40, height: contentSize.height + 40)
//        
//        let containerView = UIView()
//        containerView.addSubview(contentView)
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(messageLabel)
//        containerView.addSubview(stackView)
//        containerView.addSubview(datePicker)
//        containerView.addSubview(quantityStepper)
//        containerView.addSubview(quantityLabel)
//        containerView.addSubview(storageLocationPicker)
//        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        quantityStepper.translatesAutoresizingMaskIntoConstraints = false
//        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
//        storageLocationPicker.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(containerView)
//        containerView.center = view.center
//        
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
//            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
//            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            datePicker.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
//            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            quantityStepper.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
//            quantityStepper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            
//            quantityLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
//            quantityLabel.leadingAnchor.constraint(equalTo: quantityStepper.trailingAnchor, constant: 10),
//            quantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            storageLocationPicker.topAnchor.constraint(equalTo: quantityStepper.bottomAnchor, constant: 20),
//            storageLocationPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            storageLocationPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            storageLocationPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    private func setupButtons(_ actions: [UIAlertAction]) {
//        for action in actions {
//            let button = UIButton(type: .system)
//            button.setTitle(action.title, for: .normal)
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//            
//            if action.style == .destructive {
//                button.tintColor = .red
//            } else if action.style == .cancel {
//                button.tintColor = .systemBlue
//            }
//            
//            stackView.addArrangedSubview(button)
//            buttons.append(button)
//        }
//    }
//    
//    private func setupDatePicker() {
//        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
//    }
//
//        
//        private func setupQuantityStepper() {
//            quantityStepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
//        }
//        
//        private func setupStorageLocationPicker() {
//            storageLocationPicker.dataSource = self
//            storageLocationPicker.delegate = self
//        }
//        
//        @objc private func buttonTapped(_ sender: UIButton) {
//            guard let index = buttons.firstIndex(of: sender) else { return }
//            let action = buttons[index].currentTitle!
//            print("Button tapped: \(action)")
//            
//            // Perform the desired action based on the button tapped
//            // ...
//            
//            dismiss(animated: true, completion: nil)
//        }
//        
//        @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            let selectedDate = dateFormatter.string(from: sender.date)
//            print("Selected Date: \(selectedDate)")
//        }
//        
//        @objc private func stepperValueChanged(_ sender: UIStepper) {
//            quantityLabel.text = "Quantity: \(Int(sender.value))"
//        }
//    }
//
//    extension CustomAlertController: UIPickerViewDataSource, UIPickerViewDelegate {
//        func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            return storageLocations.count
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            return storageLocations[row]
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            print("Selected Storage Location: \(storageLocations[row])")
//        }
//    }
//
//    extension CustomAlertController: UIViewControllerTransitioningDelegate {
//        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
//        }
//    }
//
//class CustomPresentationController: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        return containerView?.bounds ?? CGRect.zero
//    }
//    
//    override func dismissalTransitionWillBegin() {
//        presentingViewController.beginAppearanceTransition(false, animated: true)
//    }
//    
//    override func dismissalTransitionDidEnd(_ completed: Bool) {
//        presentingViewController.endAppearanceTransition()
//        if completed {
//            presentingViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//}


import UIKit

class CustomAlertController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var addButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    let storageLocations = ["Pantry", "Fridge", "Freezer", "Shelf"]
    
    var productTitle : String?
    
    
    
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
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    
    @objc private func closeButtonTapped() {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func stepperTapped(_ sender: UIStepper, forEvent event: UIEvent) {
        let newValue = Int(sender.value)
        quantityLabel.text = "\(newValue)"
        
        
    }
    @objc func addButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        print("Add")

        // Print the selected date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged() {
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

