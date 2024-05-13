//
//  HouseholdViewController.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import UIKit

class HouseholdViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, HouseholdDelegate {
    func nameChanged() {
        print("see")
        householdTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HouseholdData.getInstance().householdMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = householdTableView.dequeueReusableCell(withIdentifier: "HouseholdTableViewCell", for: indexPath) as! HouseholdTableViewCell
        
        let member = HouseholdData.getInstance().householdMembers[indexPath.row]
        if let image = member.image {
            cell.memberImage.image = image
            cell.memberImage.contentMode = .scaleAspectFill
            print("Member image found")
        }else{
            let path = "images/\(member.profilePictureFileName)"
            StorageManager.shared.downloadURL(for: path, completion: {result in
                switch result {
                case .success(let url) :
                    self.downloadImage(from: url){ image in
                        if let image = image {
                            DispatchQueue.main.async {
                                cell.memberImage.image = image
                                cell.memberImage.contentMode = .scaleAspectFill
                                member.image = image
                                self.householdProfileViewController?.memberImage.image = image
                                print("Member image set")
                            }
                            
                        }
                    }
                case .failure(let error) :
                    print("image not set")
                }
            })
        }
        cell.memberImage.layer.cornerRadius = 25
        cell.memberNameLabel.text = member.firstName
        cell.memberStreakLabel.text = "\(member.currentStreak) Days"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        UserData.getInstance().user?.household?.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
            
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 40)
    
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.text = UserData.getInstance().user?.household?.name
        headerView.addSubview(titleLabel)
            
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to download image:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UserData.getInstance().users[0].badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = householdCollectionView.dequeueReusableCell(withReuseIdentifier: "HouseholdCollectionViewCell", for: indexPath) as! HouseholdCollectionViewCell
        let user = UserData.getInstance().users[0]
        let badge = user.badges[indexPath.row]
        
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
//    
    
        return cell
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        let member = sender.location(in: householdTableView)
        if let indexPath = householdTableView.indexPathForRow(at: member){
            performSegue(withIdentifier: "HouseholdProfileSegue", sender: indexPath)
        }
    }
    
    
    var householdNavigationController : HouseholdNavigationController?
    
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
    
    @IBOutlet var householdCollectionView: UICollectionView!
    @IBOutlet var householdTableView: UITableView!
    
    var householdProfileViewController : HouseholdProfileViewController?
    
    let titles = ["Expired", "Current Streak", "Max Streak"]
    let cellColors = ["#FFC6CD", "#EAFFB6", "#EFEFEF"]
    let circleColors = ["#D70015", "#43A40D", "#737373"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        householdCollectionView.dataSource = self
        householdCollectionView.delegate = self
//        householdCollectionView.isScrollEnabled = false
        householdCollectionView.alwaysBounceVertical = false
        householdCollectionView.collectionViewLayout = generateGridLayout()
        householdCollectionView.layer.cornerRadius = 10
        
        householdTableView.dataSource = self
        householdTableView.delegate = self
        householdTableView.isScrollEnabled = false
        
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HouseholdProfileSegue" {
            print("Segg")
            if let householdProfileViewController = segue.destination as? HouseholdProfileViewController, let indexPath = sender as? IndexPath{
                let member = HouseholdData.getInstance().householdMembers[indexPath.row]
                householdProfileViewController.member = member
                householdProfileViewController.householdViewcontroller = self
                self.householdProfileViewController = householdProfileViewController
            }
        }
    }

}

extension UIView {
    func applyGradient(colors: [UIColor], locations: [NSNumber]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations // Adjust as needed
        
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: min(bounds.width, bounds.height) / 2)
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
