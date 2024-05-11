//
//  AccountHouseholdViewController.swift
//  Stored
//
//  Created by student on 06/05/24.
//

import UIKit

class AccountHouseholdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var accountViewController : AccountViewController?
    var members : [User]?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            1
        case 1:
            members?.count ?? 0
        case 2:
            1
        default:
            0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = accountHouseholdTableView.dequeueReusableCell(withIdentifier: "AccountHouseholdTextFieldTableViewCell", for: indexPath) as! AccountHouseholdTextFieldTableViewCell
            cell.houseHoldTextField.text = UserData.getInstance().user?.household?.name
            cell.household = UserData.getInstance().user?.household
            cell.accountDelegate = accountViewController
            cell.householdDelegate = accountViewController!.accountNavigtionController?.storedTabBarController?.householdNavigationController?.householdViewController
            return cell
        }else if indexPath.section == 1{
            let cell = accountHouseholdTableView.dequeueReusableCell(withIdentifier: "AccountHouseholdUserTableViewCell", for: indexPath) as! AccountHouseholdUserTableViewCell
            guard let user = members?[indexPath.row] else {return UITableViewCell()}
            cell.userImage.image = UIImage(named: user.firstName)
            cell.userImage.layer.cornerRadius = 25
            cell.userLabel.text = user.firstName
            cell.userEmailLabel.text = user.email
            return cell
        }else{
            let cell = accountHouseholdTableView.dequeueReusableCell(withIdentifier: "AccountHouseholdCodeTableViewCell", for: indexPath) as! AccountHouseholdCodeTableViewCell
            cell.codeLabel.text = "\(UserData.getInstance().user?.household?.code)"
            return cell
        }
    }
    
    let sections = ["", "Members", "Household Code"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
            
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 5, y: 0, width: tableView.frame.width - 30, height: 10)
    
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .darkGray
        titleLabel.text = sections[section]
        headerView.addSubview(titleLabel)
        if section == 0 {
            titleLabel.frame = CGRect(x: 5, y: 0, width: 0, height: 0)
            titleLabel.text = ""
        }
        return headerView
    }
    
    @IBOutlet var accountHouseholdTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        accountHouseholdTableView.dataSource = self
        accountHouseholdTableView.delegate  = self
        accountHouseholdTableView.isScrollEnabled = false
        if let household = UserData.getInstance().user?.household {
            var filteredUsers: [User] = []
            for user in UserData.getInstance().users {
                if user.household?.name == household.name {
                    filteredUsers.append(user)
                }
            }
            members = filteredUsers
        }
        // Do any additional setup after loading the view.
    }
    

}
