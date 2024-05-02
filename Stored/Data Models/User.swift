struct User {
    var firstName: String
    var lastName: String
    var email: String
    var household: Household
    
    var expiredItems: Int
    var currentStreak: Int
    var maxStreak: Int
    
    init(firstName: String, lastName: String, email: String, household: Household, expiredItems: Int = 0, currentStreak: Int = 0, maxStreak: Int = 0) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.household = household
        self.expiredItems = expiredItems
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        household.members.append(self)
    }
}


class UserData {
    private static var instance = UserData()
    private init() {}
    static func getInstance() -> UserData {
        instance
    }
    
    let users = [
        User(firstName: "Olivia", lastName: "Rodrigo", email: "olivia98@example.com", household: HouseholdData.getInstance().household, expiredItems: 8, currentStreak: 7, maxStreak: 7),
        User(firstName: "Anna", lastName: "Hathaway", email: "anna33@example.com", household: HouseholdData.getInstance().household, expiredItems: 5, currentStreak: 10, maxStreak: 15),
        User(firstName: "Steve", lastName: "Jobs", email: "steve07@example.com", household: HouseholdData.getInstance().household, expiredItems: 10, currentStreak: 20, maxStreak: 30)
    ]

}
