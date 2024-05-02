//
//  HouseholdViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UserData.getInstance().users.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = householdTableView.dequeueReusableCell(withIdentifier: "HouseholdTableViewCell", for: indexPath) as! HouseholdTableViewCell
        
        let member = UserData.getInstance().users[indexPath.row + 1]
        cell.memberImage.image = UIImage(named: member.firstName)
        cell.memberImage.layer.cornerRadius = 25
        cell.memberNameLabel.text = member.firstName
        cell.memberStreakLabel.text = "\(member.currentStreak) Days"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        HouseholdData.getInstance().household.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
            
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 40)
    
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.text = HouseholdData.getInstance().household.name
        headerView.addSubview(titleLabel)
            
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = householdCollectionView.dequeueReusableCell(withReuseIdentifier: "HouseholdCollectionViewCell", for: indexPath) as! HouseholdCollectionViewCell
        cell.circleStack.layer.cornerRadius = 33
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(hex: cellColors[indexPath.row])
        cell.circleStack.backgroundColor = UIColor(hex: circleColors[indexPath.row])
        
        cell.titleLabel.text = titles[indexPath.row]
        cell.descLabel.textColor = .white
        if indexPath.row == 0{
            cell.descLabel.text = "\(UserData.getInstance().users[0].expiredItems) Items"
        }else if indexPath.row == 1 {
            cell.descLabel.text = "\(UserData.getInstance().users[0].currentStreak) Days"
        }else {
            cell.descLabel.text = "\(UserData.getInstance().users[0].maxStreak) Days"
        }
        
        
        
        cell.layer.cornerRadius = 10
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowRadius = 1
        cell.layer.masksToBounds = false
        
        cell.circleStack.layer.shadowColor = UIColor.black.cgColor
        cell.circleStack.layer.shadowOpacity = 0.2
        cell.circleStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.circleStack.layer.shadowRadius = 1
    
        return cell
        
    }
    

    @IBOutlet var householdCollectionView: UICollectionView!
    @IBOutlet var householdTableView: UITableView!
    
    let titles = ["Expired", "Current Streak", "Max Streak"]
    let descriptions = ["8 Items", "7 Days", "7 Days"]
    let cellColors = ["#FFC6CD", "#EAFFB6", "#EFEFEF"]
    let circleColors = ["#D70015", "#43A40D", "#737373"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        householdCollectionView.dataSource = self
        householdCollectionView.delegate = self
        householdCollectionView.isScrollEnabled = false
        householdCollectionView.collectionViewLayout = generateGridLayout()
        householdCollectionView.layer.cornerRadius = 10
        
        householdTableView.dataSource = self
        householdTableView.delegate = self
        householdTableView.isScrollEnabled = false
        

    }
 

    func generateGridLayout() -> UICollectionViewLayout {
        
        let padding : CGFloat = 10
        // Items dimension will be equal to group dimension
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        // Group dimension will have 1/4th of the section
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1)), subitem: item, count: 3)
        
        group.interItemSpacing = .fixed(padding)

        group.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        
                
//        section.boundarySupplementaryItems = [generateHeader()]
        
        return UICollectionViewCompositionalLayout(section: section)
        
    }

}
