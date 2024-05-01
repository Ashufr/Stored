import Foundation

struct Item {
    var name : String
    var quantity : Int
    var storage : String
    var expiryDate : Date
    
    
    var isExpired : Bool {
        return ItemData.getInstance().calulateDateDifference(startDate: Date(), endDate: expiryDate) < 0
    }
    var expiryDescription : String {
        let days = ItemData.getInstance().calulateDateDifference(startDate: Date(), endDate: expiryDate)
        if days == 0{
            return "Expires Today"
        }else if days == 1 {
            return "Expires in 1 day"
        }else if days > 1 {
            return "Expires in \(days) days"
        }
        else{
            return "Expired \(days * -1) days ago"
        }
    }
    
    init(name: String, quantity: Int, storage: String, expiryDate: Date) {
        self.name = name
        self.quantity = quantity
        self.storage = storage
        self.expiryDate = expiryDate
    }
    
}

class ItemData{
    private static var instance = ItemData();
    private init(){}
    static func getInstance() -> ItemData{
        instance
    }
    
    func calulateDateDifference(startDate : Date, endDate : Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
//        print(components)
        return components.day!
    }
    let recentlyAddedItems: [Item] = [
        Item(name: "Tomatoes", quantity: 5, storage: "Pantry", expiryDate: Date(timeIntervalSinceNow: 172800)),
        Item(name: "Chicken Breast", quantity: 3, storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 259200)),
        Item(name: "Ice Cream", quantity: 2, storage: "Freezer", expiryDate: Date(timeIntervalSinceNow: 345600))
    ]

    let pantryItems: [Item] = [
        Item(name: "Rice", quantity: 7, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!), // expiring in 3 days
        Item(name: "Pasta", quantity: 4, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 5 days
        Item(name: "Canned Beans", quantity: 2, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 7 days
        Item(name: "Cereal", quantity: 1, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!), // expiring in 10 days
        Item(name: "Flour", quantity: 6, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!), // expiring in 15 days
        Item(name: "Sugar", quantity: 9, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!), // expiring in 20 days
        Item(name: "Salt", quantity: 8, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!), // expiring in 25 days
        Item(name: "Olive Oil", quantity: 3, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!), // expiring in 30 days
        Item(name: "Canned Soup", quantity: 1, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 35, to: Date())!), // expiring in 35 days
        Item(name: "Dried Beans", quantity: 5, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!), // expiring in 40 days
        Item(name: "Peanut Butter", quantity: 2, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 65, to: Date())!) // expiring in 45 days
    ]

    let fridgeItems: [Item] = [
        Item(name: "Milk", quantity: 4, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!), // expiring in 2 days
        Item(name: "Cheese", quantity: 6, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
        Item(name: "Yogurt", quantity: 3, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!), // expiring in 4 days
        Item(name: "Eggs", quantity: 5, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!), // expiring in 5 days
        Item(name: "Butter", quantity: 2, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!) // expiring in 6 days
    ]

    let freezerItems: [Item] = [
        Item(name: "Frozen Vegetables", quantity: 8, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
        Item(name: "Ice Cream", quantity: 1, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 5 days
        Item(name: "Frozen Pizza", quantity: 3, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 7 days
        Item(name: "Frozen Chicken", quantity: 4, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!), // expiring in 10 days
        Item(name: "Frozen Fish", quantity: 2, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!) // expiring in 15 days
    ]

    let shelfItems: [Item] = [
        Item(name: "Chips", quantity: 6, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
        Item(name: "Cookies", quantity: 4, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!), // expiring in 4 days
        Item(name: "Crackers", quantity: 3, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!), // expiring in 5 days
        Item(name: "Pretzels", quantity: 2, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!) // expiring in 6 days
    ]

}


