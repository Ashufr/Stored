//
//  AccountHouseholdTableViewCell.swift
//  Stored
//
//  Created by student on 06/05/24.
//

import UIKit

protocol HouseholdDelegate {
    func nameChanged()
}

class AccountHouseholdTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    var accountDelegate : HouseholdDelegate?
    var householdDelegate : HouseholdDelegate?
    
    var household: Household?
    @IBOutlet var houseHoldTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        houseHoldTextField.delegate = self
    }

    @IBAction func handleChange(_ sender: UITextField, forEvent event: UIEvent) {
        // Handle text change
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        
        
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Show keyboard when text field is tapped
        textField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss keyboard when user taps outside the text field
        houseHoldTextField.resignFirstResponder()
    }
}

