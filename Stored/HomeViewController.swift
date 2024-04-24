//
//  ViewController.swift
//  Stored
//
//  Created by student on 18/04/24.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!
    
    var items = [Item(name: "Chocolate", storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 864000)), Item(name: "Chips", storage: "Shelf", expiryDate: Date(timeIntervalSinceNow: 432000)), Item(name: "Ice Cream", storage: "Freezer", expiryDate: Date(timeIntervalSinceNow: 1000000))]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        
        let item = items[indexPath.row]
        cell.itemNameLabel.text = item.name
        cell.itemExpiryLabel.text = item.expiryDescription
        cell.storageLabel.text = item.storage
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }


}

