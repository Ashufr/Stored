import Foundation
import UIKit

class User {
    var mid : String?
    var firstName: String
    var lastName: String
    var email: String
    var household: Household
    var expiredItems: Int
    var currentStreak: Int
    var maxStreak: Int
    var badges : [Badge]
    var imageURL : URL?
    var image : UIImage?
    
    init(firstName: String, lastName: String, email: String, household: Household, expiredItems: Int = 0, currentStreak: Int = 0, maxStreak: Int = 0) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.household = household
        self.expiredItems = expiredItems
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        self.badges = []
        
    }
    
    init(mid: String, firstName: String, lastName: String, email: String, household: Household, expiredItems: Int = 0, currentStreak: Int = 0, maxStreak: Int = 0, imageUrl : String) {
        self.mid = mid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.household = household
        self.expiredItems = expiredItems
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        self.badges = []
        self.imageURL = URL(string: imageUrl)
        
    }
    
    func addBadge(badge : Badge){
        self.badges.append(badge)
        self.badges.sort { $0.name < $1.name }
    }
}



class UserData {
    private static var instance = UserData()
    private init() {
        users[0].addBadge(badge: BadgeData.getInstance().januaryBadge)
        users[0].addBadge(badge: BadgeData.getInstance().februaryBadge)
        users[0].addBadge(badge: BadgeData.getInstance().marchBadge)
        users[0].addBadge(badge: BadgeData.getInstance().days100Badge)
        users[0].addBadge(badge: BadgeData.getInstance().julyBadge)


        // Adding random badges to Anna Hathaway
        users[1].addBadge(badge: BadgeData.getInstance().aprilBadge)
        users[1].addBadge(badge: BadgeData.getInstance().mayBadge)
        users[1].addBadge(badge: BadgeData.getInstance().juneBadge)
        users[1].addBadge(badge: BadgeData.getInstance().days50Badge)


        // Adding random badges to Steve Jobs
        users[2].addBadge(badge: BadgeData.getInstance().julyBadge)
        users[2].addBadge(badge: BadgeData.getInstance().augustBadge)
        users[2].addBadge(badge: BadgeData.getInstance().septemberBadge)
        users[2].addBadge(badge: BadgeData.getInstance().januaryBadge)
        users[2].addBadge(badge: BadgeData.getInstance().days50Badge)
        users[2].addBadge(badge: BadgeData.getInstance().novemberBadge)
        
        
    }
    static func getInstance() -> UserData {
        instance
    }
    
    var users = [
        User(firstName: "Olivia", lastName: "Rodrigo", email: "olivia98@example.com", household: HouseholdData.getInstance().household, expiredItems: 8, currentStreak: 7, maxStreak: 7),
        User(firstName: "Anna", lastName: "Hathaway", email: "anna33@example.com", household: HouseholdData.getInstance().household, expiredItems: 5, currentStreak: 10, maxStreak: 15),
        User(firstName: "Steve", lastName: "Jobs", email: "steve07@example.com", household: HouseholdData.getInstance().household, expiredItems: 10, currentStreak: 20, maxStreak: 30)
    ]
    var user : User?
    
    func fetchUsersFromURL(storedTabBarController : StoredTabBarController) {
        guard let householdID = HouseholdData.getInstance().house?.mid else {
                print("Household ID not available")
                return
            }
            
            let url = "https://ios-backend.vercel.app/api/users"
            guard let usersURL = URL(string: url) else {
                print("Invalid users URL")
                return
            }
            
            let usersTask = URLSession.shared.dataTask(with: usersURL) { data, _, error in
                guard let data = data, error == nil else {
                    print("Error fetching users data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    if let usersJson = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        var usersWithSameHousehold: [User] = []
                        for userData in usersJson {
                            print(userData)
                            guard let userHouseholdID = userData["household"] as? String else {
                                continue
                            }
                            
                            if userHouseholdID == householdID {
                                // Extract user data and initialize User object
                                let mid = userData["_id"] as? String ?? ""
                                let firstName = userData["firstName"] as? String ?? ""
                                let lastName = userData["lastName"] as? String ?? ""
                                let email = userData["email"] as? String ?? ""
                                let imageUrl = userData["imageUrl"] as? String ?? ""
                                let expiredItems = userData["expiredItems"] as? Int ?? 0
                                let currentStreak = userData["currentStreak"] as? Int ?? 0
                                let maxStreak = userData["maxStreak"] as? Int ?? 0
                                let user = User(mid: mid, firstName: firstName, lastName: lastName, email: email, household: HouseholdData.getInstance().house ?? Household(name: ""), expiredItems: expiredItems, currentStreak: currentStreak, maxStreak: maxStreak, imageUrl: imageUrl)
                                
                                usersWithSameHousehold.append(user)
                            }
                        }
                        
                        // Update members with users from the same household
                        DispatchQueue.main.async {
                            HouseholdData.getInstance().members = usersWithSameHousehold
                            storedTabBarController.accountNavigationController?.accountViewController?.accountHouseholdController?.accountHouseholdTableView.reloadData()
                        }
                        
                    }
                } catch {
                    print("Error parsing users JSON: \(error.localizedDescription)")
                }
            }
            
            // Start users data task
            usersTask.resume()
        }
    
    func fetchDataFromURL(storedTabBarController: StoredTabBarController) {
        let userURLString = "https://ios-backend.vercel.app/api/users/6638f2587a23b949f012158a"
        
        guard let userURL = URL(string: userURLString) else {
            print("Invalid user URL")
            return
        }
        
        var newUser: User?
        var newHouse: Household?
        
        let userTask = URLSession.shared.dataTask(with: userURL) { userData, _, userError in
            guard let userData = userData, userError == nil else {
                print("Error fetching user data: \(userError?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // Parse JSON user data
                if let userJson = try JSONSerialization.jsonObject(with: userData) as? [String: Any] {
                    // Extract householdId from user data
                    guard let householdId = userJson["household"] as? String else {
                        print("Household ID not found in user data")
                        return
                    }
                    
                    // Fetch household data using householdId
                    let householdURLString = "https://ios-backend.vercel.app/api/households/\(householdId)"
                    guard let householdURL = URL(string: householdURLString) else {
                        print("Invalid household URL")
                        return
                    }
                    
                    let householdTask = URLSession.shared.dataTask(with: householdURL) { householdData, _, householdError in
                        guard let householdData = householdData, householdError == nil else {
                            print("Error fetching household data: \(householdError?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        do {
                            // Parse JSON household data
                            if let householdJson = try JSONSerialization.jsonObject(with: householdData) as? [String: Any] {
                                // Extract household name from household data
                                guard let householdName = householdJson["name"] as? String else {
                                    print("Household name not found in household data")
                                    return
                                }
                                var storagesArray = [Storage]()
                                if let storages =  householdJson["storages"] as? [[String: Any]]{
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    for storage in storages {
                                        var itemsArray = [Item]()
                                        if let items = storage["items"] as? [[String: Any]]{
                                            for item in items {
                                                let itemMid = item["_id"] as? String ?? ""
                                                let itemName = item["name"] as? String ?? ""
                                                let itemQuatity = item["quantity"] as? Int ?? 1
                                                let itemStorage = item["storage"] as? String ?? ""
                                                let expiryDateString = item["expiryDate"] as? String ?? ""
                                                let expiryDate = dateFormatter.date(from: expiryDateString)!
                                                let imageUrl = item["imageUrl"] as? String ?? ""
                                                let dateAddedString = item["dateAdded"] as? String ?? ""
                                                let dateAdded = dateFormatter.date(from: dateAddedString)!
                                                let item = Item(mid: itemMid, name: itemName, quantity: itemQuatity, storage: itemStorage, expiryDate: expiryDate, imageUrl: imageUrl)
                                                itemsArray.append(item)
                                                
                                            }
                                            let newStorage = Storage(mid : storage["_id"] as? String ?? "", name: storage["name"] as! String, items: itemsArray)
                                            storagesArray.append(newStorage)
                                            print(newStorage.mid)
                                        }
                                    }
                                }else{
                                    print("no strrotr")
                                }
                                
                                
                                
                                
                                
                                let household = Household(mid: householdId, name: householdName, storages: storagesArray)
                                
                                DispatchQueue.main.async {
                                    storedTabBarController.expiringNavigationController?.expiringViewController!.itemAdded()
                                    storedTabBarController.expiringNavigationController?.expiringViewController?.expiredViewController?.expiredTableView.reloadData()
                                    storedTabBarController.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                                    storedTabBarController.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                                }
                                
                                
                                HouseholdData.getInstance().house = household
                                // Extract user data and initialize a User object
                                let mid = userJson["_id"] as? String ?? ""
                                let firstName = userJson["firstName"] as? String ?? ""
                                let lastName = userJson["lastName"] as? String ?? ""
                                let email = userJson["email"] as? String ?? ""
                                let imageUrl = userJson["imageUrl"] as? String ?? ""
                                let expiredItems = userJson["expiredItems"] as? Int ?? 0
                                let currentStreak = userJson["currentStreak"] as? Int ?? 0
                                let maxStreak = userJson["maxStreak"] as? Int ?? 0
                                let user = User(mid: mid, firstName: firstName, lastName: lastName, email: email, household: household, expiredItems: expiredItems, currentStreak: currentStreak, maxStreak: maxStreak, imageUrl: imageUrl)
                                
                                // Set newUser and newHouse inside the completion handler
                                newUser = user
                                newHouse = household
                                self.user = user
                                // Update UI on the main thread
                                DispatchQueue.main.async {
                                    // Set user and household properties
                                    storedTabBarController.accountNavigationController?.accountViewController?.user = newUser
                                    storedTabBarController.accountNavigationController?.accountViewController?.household = newHouse
                                    // Reload the table view
                                    storedTabBarController.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)], with: .automatic)
                                    UserData.getInstance().fetchUsersFromURL(storedTabBarController : storedTabBarController)
                                    print("releooeoeooe")
                                }
                                
                                if let user = newUser {
                                    print("User: \(user.firstName) \(user.lastName), Email: \(user.email), Household: \(user.household.name)")
                                } else {
                                    print("Failed to initialize user object")
                                }
                            }
                        } catch {
                            print("Error parsing household JSON: \(error.localizedDescription)")
                        }
                    }
                    
                    // Start household data task
                    householdTask.resume()
                }
            } catch {
                print("Error parsing user JSON: \(error.localizedDescription)")
            }
        }
        
        // Start user data task
        userTask.resume()
    }
    
    

    

}


