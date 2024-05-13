import Foundation

class StorageLocation {
    var name : String
    var items : [Item] {
        didSet {
            print("item added to \(self.name)")
        }
    }
    
    var count : Int {
        items.count
    }
    init(name: String, items: [Item]) {
        self.name = name
        self.items = items
        StorageLocation.allInstances.append(self)
    }
    
    private static var allInstances = [StorageLocation]()
    
    static var all: StorageLocation {
        var allItems = [Item]()
        var itemIdentifierSet = Set<String>()
        
        // Aggregate items from all storage instances
        for storageInstance in allInstances {
            for item in storageInstance.items {
                // Check if the item identifier has alrea   dy been added
                if !itemIdentifierSet.contains(item.name) {
                    allItems.append(item)
                    itemIdentifierSet.insert(item.name)
                }
            }
        }
        
        return StorageLocation(name: "All", items: allItems)
    }
    
    
    init(name: String, items: [[Item]]) {
        self.name = name
        var arrray = [Item]()
        for itemss in items {
            for item in itemss {
                arrray.append(item)
            }
        }
        self.items = arrray
        StorageLocation.allInstances.append(self)
    }
    
}


enum ExpiryCategory {
    case expired
    case today
    case tomorrow
    case thisWeek
    case thisMonth
    case later
}

class StorageLocationData {
    
    var storages: [StorageLocation] = [
//        StorageLocation(name: "Pantry", items: ItemData.getInstance().pantryItems),
//        StorageLocation(name: "Fridge", items: ItemData.getInstance().fridgeItems),
//        StorageLocation(name: "Freezer", items: ItemData.getInstance().freezerItems),
//        StorageLocation(name: "Shelf", items: ItemData.getInstance().shelfItems),
//        StorageLocation(name: "All", items:[ItemData.getInstance().pantryItems,ItemData.getInstance().fridgeItems,ItemData.getInstance().freezerItems,ItemData.getInstance().shelfItems])
    ]
    
    private static var instance: StorageLocationData = StorageLocationData()
    
    private init() {}
    
    static func getInstance() -> StorageLocationData{
        return instance
    }
    
    
    func categorizeStorageItems(_ items: [Item]) -> [ExpiryCategory: [Item]] {
        let calendar = Calendar.current
        let currentDate = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        var categorizedStorage: [ExpiryCategory: [Item]] = [
            .expired: [],
            .today: [],
            .thisMonth: [],
            .later: []
        ]
        
        for item in items {
            let expiryDate = item.expiryDate
            let daysDifference = calendar.dateComponents([.day], from: currentDate, to: expiryDate).day ?? 0
            
            if daysDifference < 0 {
                categorizedStorage[.expired]?.append(item)
            } else if calendar.isDate(expiryDate, inSameDayAs: currentDate) {
                categorizedStorage[.today]?.append(item)
            } else if calendar.component(.month, from: expiryDate) == calendar.component(.month, from: currentDate) && calendar.component(.year, from: expiryDate) == calendar.component(.year, from: currentDate){
                categorizedStorage[.thisMonth]?.append(item)
            } else {
                categorizedStorage[.later]?.append(item)
            }
        }
        
        for (category, items) in categorizedStorage {
            categorizedStorage[category] = items.sorted(by: { $0.expiryDate < $1.expiryDate })
        }
        return categorizedStorage
    }
    
    func categorizeExpiringItems(_ items: [Item]) -> [ExpiryCategory: [Item]] {
        let calendar = Calendar.current
        let currentDate = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"
        
        
        var categorizedStorage: [ExpiryCategory: [Item]] = [
            .today: [],
            .tomorrow: [],
            .thisWeek: [],
        ]
        
        for item in items {
            let expiryDate = item.expiryDate
            
            let c = Int(dateformatter.string(from: Date()))!
            let e = Int(dateformatter.string(from: expiryDate))!
            
            let weekday = calendar.component(.weekday, from: Date())
            
            // Calculate the number of days to subtract to get to the last Sunday
            let daysToSubtract = weekday - 1
            
            // Create a date component with the number of days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract
            
            // Get the last Sunday by subtracting the days from today
            
            let w = Int(dateformatter.string(from: calendar.date(byAdding: dateComponents, to: Date())!))!
            
            
            if c == e{
                categorizedStorage[.today]?.append(item)
            } else if e <= c + 1 && e > c{
                categorizedStorage[.tomorrow]?.append(item)
            } else if e <= w + 7 && e > c{
                categorizedStorage[.thisWeek]?.append(item)
            }
        }
        
        for (category, items) in categorizedStorage {
            categorizedStorage[category] = items.sorted(by: { $0.expiryDate < $1.expiryDate })
        }
        return categorizedStorage
    }


    
    func getStorageIndex(for storage : String) -> Int {
        switch storage {
        case "Shelf":
            return 0
        case "Pantry":
            return 1
        case "Fridge":
            return 2
        case "Freezer":
            return 3
        default:
            return 4
        }
    }
    
    func getExpiryCategory(forString stringValue: String) -> ExpiryCategory {
        switch stringValue {
        case "Expired":
            return .expired
        case "Today":
            return .today
        case "Tomorrow":
            return .tomorrow
        case "This Week":
            return .thisWeek
        case "This Month":
            return .thisMonth
        default:
            return .later
        }
    }
    
    
}
