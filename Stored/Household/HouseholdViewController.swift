//
//  HouseholdViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = householdCollectionView.dequeueReusableCell(withReuseIdentifier: "HouseholdCollectionViewCell", for: indexPath) as! HouseholdCollectionViewCell
        cell.circleStack.layer.cornerRadius = 33
        cell.layer.cornerRadius = 10
        return cell
        
    }
    

    @IBOutlet var householdCollectionView: UICollectionView!
    
    let titles = ["Expired", "Current Streak", "Max Streak"]
    let descriptions = ["8 Items", "7 Days", "7 Days"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        householdCollectionView.dataSource = self
        householdCollectionView.delegate = self
        householdCollectionView.isScrollEnabled = false
        householdCollectionView.collectionViewLayout = generateGridLayout()
        householdCollectionView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
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
