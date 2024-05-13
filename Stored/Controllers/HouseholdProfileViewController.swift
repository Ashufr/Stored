//
//  HouseholdProfileViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var member : User?
    var householdViewcontroller : HouseholdViewController?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        member?.badges.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
        let cell = householdProfileCollectionView.dequeueReusableCell(withReuseIdentifier: "HouseholdProfileCollectionViewCell", for: indexPath) as! HouseholdProfileCollectionViewCell
        guard let badge = member?.badges[indexPath.row] else {return cell}
        
        cell.badgeImage.image = badge.image
        cell.badgeName.text = badge.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        cell.badgeDate.text = dateFormatter.string(from: badge.dateEarned)
        
        cell.tapAction = {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                print("Unable to find window scene")
                return
            }
            
            var topViewController = window.rootViewController
            while let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            }
            
            guard let badgeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BadgeVC") as? BadgeViewController else {
                return
            }
            
            badgeController.badge = badge
            badgeController.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            badgeController.modalTransitionStyle = .crossDissolve
            badgeController.modalPresentationStyle = .overFullScreen
            badgeController.innerView.layer.cornerRadius = 10
            topViewController?.present(badgeController, animated: true, completion: nil)
        }
        
        return cell
    }
    
    let titles = ["Expired", "Current Streak", "Max Streak"]
    let cellColors = ["#FFC6CD", "#EAFFB6", "#EFEFEF"]
    let circleColors = ["#D70015", "#43A40D", "#737373"]

    @IBOutlet var outerStackView: UIStackView!
    
    @IBOutlet var expiredStackView: UIStackView!
    @IBOutlet var expiredCircleStackView: UIStackView!
    @IBOutlet var expiredLabel: UILabel!
    @IBOutlet var expiredView: UIView!
    
    @IBOutlet var currentStreakStack: UIStackView!
    @IBOutlet var currentCircleStack: UIStackView!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var currentView: UIView!
    
    @IBOutlet var maxStreakStack: UIStackView!
    @IBOutlet var maxCircleStack: UIStackView!
    @IBOutlet var maxLabel: UILabel!
    
    @IBOutlet var maxView: UIView!
    
    
    @IBOutlet var memberNameLabel: UILabel!
    @IBOutlet var memberImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        awardsView.layer.cornerRadius = 10
        householdProfileCollectionView.dataSource = self
        householdProfileCollectionView.delegate = self
//        householdProfileCollectionView.isScrollEnabled = false 
        householdProfileCollectionView.alwaysBounceVertical = false
        householdProfileCollectionView.collectionViewLayout = generateGridLayout()
        householdProfileCollectionView.layer.cornerRadius = 10
        memberImage.layer.cornerRadius = 75
        memberImage.contentMode = .scaleAspectFill
        
        if let member = member {
            memberImage.image = member.image
            memberNameLabel.text = "\(member.firstName) \(member.lastName)"
        }
        
        outerStackView.layer.cornerRadius = 20
        
        expiredStackView.layer.cornerRadius = 10
        expiredView.layer.cornerRadius = 10
        
        expiredStackView.layer.shadowColor = UIColor.black.cgColor
        expiredStackView.layer.shadowOpacity = 0.5
        expiredStackView.layer.shadowOffset = CGSize(width: 1, height: 1)
        expiredStackView.layer.shadowRadius = 1
        expiredStackView.layer.masksToBounds = false
        
        expiredCircleStackView.layer.shadowColor = UIColor.black.cgColor
        expiredCircleStackView.layer.shadowOpacity = 0.2
        expiredCircleStackView.layer.shadowOffset = CGSize(width: 0, height: 4)
        expiredCircleStackView.layer.shadowRadius = 1
        expiredCircleStackView.applyGradient(colors: [
            UIColor(red: 255/255, green: 110/255, blue: 127/255, alpha: 1.0), // 0% color
            UIColor(red: 231/255, green: 59/255, blue: 77/255, alpha: 1.0),   // 36% color
            UIColor(red: 215/255, green: 0/255, blue: 21/255, alpha: 1.0)     // 100% color
        ],locations: [0.0, 0.36, 1.0])
        
        currentStreakStack.layer.cornerRadius = 10
        currentView.layer.cornerRadius = 10
        
        currentStreakStack.layer.shadowColor = UIColor.black.cgColor
        currentStreakStack.layer.shadowOpacity = 0.5
        currentStreakStack.layer.shadowOffset = CGSize(width: 1, height: 1)
        currentStreakStack.layer.shadowRadius = 1
        currentStreakStack.layer.masksToBounds = false
        
        currentCircleStack.layer.shadowColor = UIColor.black.cgColor
        currentCircleStack.layer.shadowOpacity = 0.2
        currentCircleStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        currentCircleStack.layer.shadowRadius = 1
        currentCircleStack.applyGradient(colors: [
            UIColor(red: 155/255, green: 255/255, blue: 99/255, alpha: 1.0), // 0% color
            UIColor(red: 67/255, green: 164/255, blue: 13/255, alpha: 1.0),   // 69% color
            UIColor(red: 45/255, green: 123/255, blue: 1/255, alpha: 1.0)     // 100% color
        ],locations: [0.0, 0.69, 1.0])
        
        
        maxStreakStack.layer.cornerRadius = 10
        maxView.layer.cornerRadius = 10
        
        maxStreakStack.layer.shadowColor = UIColor.black.cgColor
        maxStreakStack.layer.shadowOpacity = 0.5
        maxStreakStack.layer.shadowOffset = CGSize(width: 1, height: 1)
        maxStreakStack.layer.shadowRadius = 1
        maxStreakStack.layer.masksToBounds = false
        
        maxCircleStack.layer.shadowColor = UIColor.black.cgColor
        maxCircleStack.layer.shadowOpacity = 0.2
        maxCircleStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        maxCircleStack.layer.shadowRadius = 1
        maxCircleStack.applyGradient(colors: [
            UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0), // 13% color
            UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 1.0), // 32% color
            UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1.0)  // 100% color
        ], locations: [0, 0.32, 1.0])
        

    }
    
    @IBOutlet var householdProfileCollectionView: UICollectionView!
    
    
    func generateGridLayout() -> UICollectionViewLayout {
        let padding: CGFloat = 10
        
        // Item size is equal to group size
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        // Group dimension will have 1/3th of the section
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitem: item,
            count: 1
        )
        
        group.interItemSpacing = .fixed(padding)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: padding,
            bottom: padding,
            trailing: padding
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }



}

