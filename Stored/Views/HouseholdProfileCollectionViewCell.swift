//
//  HouseholdProfileCollectionViewCell.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var badgeImage: UIImageView!
    @IBOutlet var badgeName: UILabel!
    @IBOutlet var badgeDate: UILabel!
    
    var tapAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        badgeImage.layer.shadowColor = UIColor.black.cgColor
        badgeImage.layer.shadowOpacity = 0.5
        badgeImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        badgeImage.layer.shadowRadius = 2
        badgeImage.layer.masksToBounds = false
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBadgeTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleBadgeTap(_ sender: UITapGestureRecognizer) {
        // Execute tap action closure when tapped
        tapAction?()
    }
}
