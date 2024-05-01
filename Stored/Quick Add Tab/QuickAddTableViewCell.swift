//
//  QuickAddTableViewCell.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class QuickAddTableViewCell: UITableViewCell {

    var item : Item?
    
    @IBOutlet var itemImage: UIImageView!
    
    @IBOutlet var itemName: UILabel!
    
    @IBOutlet var itemStepper: UIStepper!
    @IBOutlet var itemStepperLabel: UILabel!
    @IBOutlet var buttonImage: UIImageView!
    @IBOutlet var itemStack: UIStackView!
    
    @IBOutlet var imageStack: UIStackView!
    
    @IBAction func stepperTapped(_ sender: UIStepper, forEvent event: UIEvent) {
        itemStepperLabel.text = "\(Int(itemStepper.value))"
    }
}
