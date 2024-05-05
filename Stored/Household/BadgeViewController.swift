//
//  BadgeViewController.swift
//  Stored
//
//  Created by student on 05/05/24.
//

import UIKit

class BadgeViewController: UIViewController {
    
    var badge : Badge?
    
    @IBOutlet var badgeImage: UIImageView!
    @IBOutlet var innerView: UIView!
    @IBOutlet var badgeDate: UILabel!
    @IBOutlet var badgeName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        badgeImage.image = badge?.image
        badgeName.text = badge?.name
        badgeImage.layer.shadowColor = UIColor.black.cgColor
        badgeImage.layer.shadowOpacity = 0.5
        badgeImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        badgeImage.layer.shadowRadius = 2
        badgeImage.layer.masksToBounds = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        badgeDate.text = dateFormatter.string(from: badge?.dateEarned ?? Date())
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        view.addGestureRecognizer(tapGesture)
//        let tg = UITapGestureRecognizer(target: self, action: nil)
//        innerView.addGestureRecognizer(tg)
    }
    
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        // Dismiss the view controller when tapped outside its view
        dismiss(animated: true, completion: nil)
    }
    
}
