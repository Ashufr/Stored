//
//  Item.swift
//  Stored
//
//  Created by student on 24/04/24.
//

import Foundation

struct Item {
    var name : String
    var storage : String
    var expiryDate : Date
    
    
    var isExpired : Bool {
        calulateDateDifference(startDate: Date(), endDate: expiryDate) < 0
    }
    var expiryDescription : String {
        let days = calulateDateDifference(startDate: Date(), endDate: expiryDate)
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
    
}

func calulateDateDifference(startDate : Date, endDate : Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: startDate, to: endDate)
    return components.day!
}

let recentlyAddedItems = [
    Item(name: "Tomatoes", storage: "Pantry", expiryDate: Date(timeIntervalSinceNow: 172800)),
    Item(name: "Chicken Breast", storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 259200)),
    Item(name: "Ice Cream", storage: "Freezer", expiryDate: Date(timeIntervalSinceNow: 345600)),
    Item(name: "Cereal", storage: "Shelf", expiryDate: Date(timeIntervalSinceNow: 432000)),
    Item(name: "Spinach", storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 518400))
]


// Pantry items
let pantryItems: [Item] = [
    Item(name: "Rice", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!), // expiring in 3 days
    Item(name: "Pasta", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 5 days
    Item(name: "Canned Beans", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 7 days
    Item(name: "Cereal", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!), // expiring in 10 days
    Item(name: "Flour", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!), // expiring in 15 days
    Item(name: "Sugar", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!), // expiring in 20 days
    Item(name: "Salt", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!), // expiring in 25 days
    Item(name: "Olive Oil", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!), // expiring in 30 days
    Item(name: "Canned Soup", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 35, to: Date())!), // expiring in 35 days
    Item(name: "Dried Beans", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!), // expiring in 40 days
    Item(name: "Peanut Butter", storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 65, to: Date())!) // expiring in 45 days
]

// Fridge items
let fridgeItems: [Item] = [
    Item(name: "Milk", storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!), // expiring in 2 days
    Item(name: "Cheese", storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
    Item(name: "Yogurt", storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!), // expiring in 4 days
    Item(name: "Eggs", storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!), // expiring in 5 days
    Item(name: "Butter", storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!) // expiring in 6 days
]

// Freezer items
let freezerItems: [Item] = [
    Item(name: "Frozen Vegetables", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
    Item(name: "Ice Cream", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 5 days
    Item(name: "Frozen Pizza", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!), // expiring in 7 days
    Item(name: "Frozen Chicken", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!), // expiring in 10 days
    Item(name: "Frozen Fish", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!) // expiring in 15 days
]

// Shelf items
let shelfItems: [Item] = [
    Item(name: "Cereal", storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 2 days
    Item(name: "Chips", storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!), // expiring in 3 days
    Item(name: "Cookies", storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!), // expiring in 4 days
    Item(name: "Crackers", storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!), // expiring in 5 days
    Item(name: "Pretzels", storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!) // expiring in 6 days
]
