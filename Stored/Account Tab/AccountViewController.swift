

import UIKit

class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, HouseholdDelegate {
    func nameChanged() {
        // indexPath of the row you want to reload
        let indexPath = IndexPath(row: 1, section: 0)

        // Reload the row at the specified indexPath
        accountTableView.reloadRows(at: [indexPath], with: .automatic)

    }
    
    
    var household : Household?
    var user : User?
    var users : [User]?
    var members : [User]?
    
    var accountNavigtionController : AccountNavigationController?
    var accountHouseholdController : AccountHouseholdViewController?
    
    let accountData: [Int : [String]] = [0:["", "Household"], 1 : ["Manage Household", "Leave Houshold"], 2: ["Notifications"], 3: ["Help", "Privacy Statement", "Tell a Friend"]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountData[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
            guard let user = self.user else {
                print("usr nit found")
                return UITableViewCell()
            }
            if let image = user.image{
                cell.userImage.image = image
            }else{
                ItemData.getInstance().loadImageFrom(url: user.imageURL){ image in
                    if let image = image {
                        cell.userImage.image = image
                        user.image = image
                    } else {
                        // Handle case where image couldn't be loaded
                        print("Failed to load image")
                    }
                }
            }
            cell.userImage.contentMode = .scaleAspectFill
            cell.userImage.clipsToBounds = true
            cell.userImage.layer.cornerRadius = 25
            cell.userName.text = "\(user.firstName) \(user.lastName)"
            cell.userNumber.text = "\(user.email)"
            
            
            return cell
        }else if indexPath.section == 0 && indexPath.row == 1 {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
            cell.accessoryType = .none
            cell.accountSmallNameLabel.text = household?.name
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.addGestureRecognizer(tapGesture)
            return cell
        }else{
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
            
            let titles = accountData[indexPath.section]!
            let title = titles[indexPath.row]
            if indexPath.section == 0 && indexPath.row == 1 {
                cell.accessoryType = .none
                
            }
            if title == "Leave Houshold"{
                cell.accountSmallNameLabel.textColor = .red
                cell.accessoryType = .none
                
            }
            cell.accountSmallNameLabel.text = title
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.addGestureRecognizer(tapGesture)
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    

    @IBOutlet var accountTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = UserData.getInstance().user
        household = HouseholdData.getInstance().house
        if let household = household {
            var filteredUsers: [User] = []
            for user in UserData.getInstance().users {
                if user.household.name == household.name {
                    filteredUsers.append(user)
                }
            }
            users = filteredUsers
        }
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.isScrollEnabled = false
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: accountTableView)
        if let indexPath = accountTableView.indexPathForRow(at: location), indexPath == IndexPath(row: 0, section: 1){
            print(indexPath)
            performSegue(withIdentifier: "HouseholdSegue", sender: indexPath)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HouseholdSegue" {
            if let destinationVC = segue.destination as? AccountHouseholdViewController {
                destinationVC.household = household
                destinationVC.accountViewController = self
                self.accountHouseholdController = destinationVC
            }
        }
    }


}
//cell.accessoryType = .none
