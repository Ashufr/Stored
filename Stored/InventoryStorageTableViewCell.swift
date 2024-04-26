//
//  InventoryStorageTableViewCell.swift
//  Stored
//
//  Created by student on 24/04/24.
//

import UIKit

class InventoryStorageTableViewCell: UITableViewCell {

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemExpiryLabel: UILabel!
    @IBOutlet var itemQuantityLabel: UILabel!
    
    func isRed () {
        itemExpiryLabel.textColor = .red
    }

}
