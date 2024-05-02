//
//  HouseholdProfileViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var member : User?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
        let cell = householdProfileCollectionView.dequeueReusableCell(withReuseIdentifier: "HouseholdProfileCollectionViewCell", for: indexPath) as! HouseholdProfileCollectionViewCell
        cell.circleStack.layer.cornerRadius = 33
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(hex: cellColors[indexPath.row])
        cell.circleStack.backgroundColor = UIColor(hex: circleColors[indexPath.row])
        
        cell.titleLabel.text = titles[indexPath.row]
        cell.descLabel.textColor = .white
        guard let member = member else {return UICollectionViewCell()}
        if indexPath.row == 0{
            cell.descLabel.text = "\(member.expiredItems) Items"
        }else if indexPath.row == 1 {
            cell.descLabel.text = "\(member.currentStreak) Days"
        }else {
            cell.descLabel.text = "\(member.maxStreak) Days"
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
    
    let titles = ["Expired", "Current Streak", "Max Streak"]
    let cellColors = ["#FFC6CD", "#EAFFB6", "#EFEFEF"]
    let circleColors = ["#D70015", "#43A40D", "#737373"]

    @IBOutlet var awardsView: UIView!
    
    @IBOutlet var memberNameLabel: UILabel!
    @IBOutlet var memberImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awardsView.layer.cornerRadius = 10
        householdProfileCollectionView.dataSource = self
        householdProfileCollectionView.delegate = self
        householdProfileCollectionView.isScrollEnabled = false 
        householdProfileCollectionView.collectionViewLayout = generateGridLayout()
        householdProfileCollectionView.layer.cornerRadius = 10
        memberImage.layer.cornerRadius = 75
        
        if let member = member {
            memberImage.image = UIImage(named: member.firstName)
            memberNameLabel.text = "\(member.firstName) \(member.lastName)"
        }

    }
    
    @IBOutlet var householdProfileCollectionView: UICollectionView!
    
    
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
