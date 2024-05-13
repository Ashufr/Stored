import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var registerButton: UIButton!
    var storedTabBarController : StoredTabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 5
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add tap gesture recognizer to imageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        if let placeholder = nameTextField.placeholder {
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        if let placeholder = lastNameTextField.placeholder {
            lastNameTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        
        if let placeholder = emailTextField.placeholder {
            emailTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        if let placeholder = passwordTextField.placeholder {
            passwordTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
        if let placeholder = confirmPasswordTextField.placeholder {
            confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Description Color")!]
            )
        }
    }
    
    
    // MARK: - Image Handling
    
    @objc func imageViewTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
            imageView.contentMode = .scaleAspectFill
        }
        imageView.layer.cornerRadius = 75
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Register Button Action
    
    @IBAction func didTapRegister() {
        guard let firstName = nameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let image = imageView.image, image.isSymbolImage == false else { return }
        
        guard passwordTextField.text == confirmPasswordTextField.text else {
            let alertController = UIAlertController(title: "Check Password", message: "The passwords you have typed don't match", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        DatabaseManager.shared.userExists(with: email, completion: { [ weak self ] exist in
            
            guard let strongSelf = self else {
                return
            }
            guard !exist else {
                print("User already Exists")
                let alertController = UIAlertController(title: "User Already Exists", message: "This user already exists.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                strongSelf.present(alertController, animated: true, completion: nil)
                return
            }
            
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    strongSelf.present(alertController, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    
                    let user = User(firstName: firstName, lastName: lastName, email: email)
                    UserData.getInstance().user = user
                    strongSelf.performSegue(withIdentifier: "JoinCreateSegue", sender: user)
                    DatabaseManager.shared.insertUser(with: user) { success in
                        if success {
                            strongSelf.uploadProfilePicture(for: user, image: image)
                        }
                    }
                }
            }
        })
    }
    
    func uploadProfilePicture(for user: User, image: UIImage) {
        let safeEmail = StorageManager.safeEmail(email: user.email)
        guard let data = image.pngData() else {
            print("No Image Selected")
            return
        }
        let fileName = "\(safeEmail)_profile_picture.png"
        
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                
            case .failure(let error):
                print("Storage Manager Error : \(error)")
                strongSelf.showUploadAlert(user: user, image: image)
            }
        }
    }
    
    func showUploadAlert(user: User, image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alertController = UIAlertController(title: "Error", message: "Failed to upload profile picture. Would you like to try again?", preferredStyle: .alert)
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
                strongSelf.uploadProfilePicture(for: user, image: image)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(tryAgainAction)
            alertController.addAction(cancelAction)
            strongSelf.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let user = sender as? User, let destinationVC = segue.destination as? JoinOrCreateHouseholdViewController {
            print("Seguueu")
            destinationVC.user = user
            destinationVC.storedTabBarController = self.storedTabBarController
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
