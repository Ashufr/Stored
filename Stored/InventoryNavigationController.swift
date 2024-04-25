//
//  InventoryNavigationController.swift
//  Stored
//
//  Created by student on 25/04/24.
//

import UIKit

class InventoryNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addScanButton()
        // Do any additional setup after loading the view.
    }
}
extension UINavigationController {
    func addScanButton () {
        
        if view.viewWithTag(999) != nil {
            // Button already exists, no need to add it again
            return
        }
        
        
        let scanButton: ScanItemButton = {
            let button = ScanItemButton(type: .system)
//          button.setTitle("ScanButton", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = 999
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            return button
        }()
        
        scanButton.setupUI(in: view)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
            // Add your code here to handle the button tap
            print("Button tapped!")
        }
}
