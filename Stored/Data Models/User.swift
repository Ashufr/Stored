import Foundation
import UIKit

class User {
    var firstName: String
    var lastName: String
    var email: String
    var household: Household?
    var expiredItems: Int
    var currentStreak: Int
    var maxStreak: Int
    var badges : [Badge]
    var image : UIImage?
    
    var safeEmail : String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName : String {
        "\(safeEmail)_profile_picture.png"
    }
    
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
    
    init(firstName: String, lastName: String, email: String, expiredItems: Int = 0, currentStreak: Int = 0, maxStreak: Int = 0) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.expiredItems = expiredItems
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        self.badges = UserData.getInstance().users[Int.random(in: 0...2)].badges
    }
    
    func addBadge(badge : Badge){
        self.badges.append(badge)
        self.badges.sort { $0.name < $1.name }
    }
}



class UserData {
    private static var instance = UserData()
    private let userDefaults = UserDefaults.standard
  
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
        
        
        // Load user from device
        
    }
    
    static func getInstance() -> UserData {
        instance
    }
    
    var user: User?{
        didSet {
            print("User")
        }
    }
    
  
    
    var users = [
        User(firstName: "Olivia", lastName: "Rodrigo", email: "olivia98@example.com", household: HouseholdData.getInstance().household, expiredItems: 8, currentStreak: 7, maxStreak: 7),
        User(firstName: "Anna", lastName: "Hathaway", email: "anna33@example.com", household: HouseholdData.getInstance().household, expiredItems: 5, currentStreak: 10, maxStreak: 15),
        User(firstName: "Steve", lastName: "Jobs", email: "steve07@example.com", household: HouseholdData.getInstance().household, expiredItems: 10, currentStreak: 20, maxStreak: 30)
    ]
    
    
    
}


