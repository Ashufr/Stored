//
//  CustomAccountViewController.swift
//  Stored
//
//  Created by Student on 01/05/24.
//

import UIKit

class CustomAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = accountTableView.dequeueReusableCell(withIdentifier: "CustomAccountTableViewCell", for: indexPath) as! CustomAccountTableViewCell
//        cell.accountImage.image = UIImage(named: "user")
        cell.nameLabel.text = "Olivia House"
        cell.numberLabel.text = "+91 77430-34600"
        return cell
    }
    

    @IBOutlet weak var accountTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        accountTableView.dataSource = self
        accountTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    

}
