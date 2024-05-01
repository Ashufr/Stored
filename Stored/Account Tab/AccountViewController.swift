

import UIKit

class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let accountData: [Int : [String]] = [0:["", "Olivia's Houshold"], 1 : ["Manage Household", "Add Members", "Leave Houshold"], 2: ["Notifications"], 3: ["Help", "Privacy Statement", "Tell a Friend"]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountData[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
            cell.userImage.image = UIImage(named: "user")
            cell.userName.text = "Olivia Rodrigo"
            cell.userNumber.text = "+91 77430-34600"
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
            
            
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    

    @IBOutlet var accountTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.isScrollEnabled = false
        // Do any additional setup after loading the view.
    }
    


}
//cell.accessoryType = .none
