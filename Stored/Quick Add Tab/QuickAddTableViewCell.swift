//
//  QuickAddTableViewCell.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit



class QuickAddTableViewCell: UITableViewCell {

    var quickAddViewController : QuickAddViewController?
    var item : Item?
    
    @IBOutlet var itemImage: UIImageView!
    
    @IBOutlet var itemName: UILabel!
    
    @IBOutlet var itemStepper: UIStepper!
    @IBOutlet var itemStepperLabel: UILabel!
    @IBOutlet var buttonImage: UIImageView!
    @IBOutlet var itemStack: UIStackView!
    
    @IBOutlet var imageStack: UIStackView!
    
    @IBAction func stepperTapped(_ sender: UIStepper, forEvent event: UIEvent) {
        if itemStepper.value == 0 {
            itemStepper.value = 1
            itemStepperLabel.text = "1"
            quickAddViewController?.dismissAdding(cell: self)
        }
        itemStepperLabel.text = "\(Int(itemStepper.value))"
    }
}
