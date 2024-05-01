import Foundation

class Storage {
    var name : String
    var items : [Item]
    
    var count : Int {
        items.count
    }
    
    private static var allInstances = [Storage]()
    
    static var all: Storage {
        var allItems = [Item]()
        var itemIdentifierSet = Set<String>()
        
        // Aggregate items from all storage instances
        for storageInstance in allInstances {
            for item in storageInstance.items {
                // Check if the item identifier has already been added
                if !itemIdentifierSet.contains(item.name) {
                    allItems.append(item)
                    itemIdentifierSet.insert(item.name)
                }
            }
        }
        
        return Storage(name: "All", items: allItems)
    }
    
    init(name: String, items: [Item]) {
        self.name = name
        self.items = items
        Storage.allInstances.append(self)
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

class StorageData {
    
    var storages: [Storage] = [
        Storage(name: "Pantry", items: ItemData.getInstance().pantryItems),
        Storage(name: "Fridge", items: ItemData.getInstance().fridgeItems),
        Storage(name: "Freezer", items: ItemData.getInstance().freezerItems),
        Storage(name: "Shelf", items: ItemData.getInstance().shelfItems)
    ]
    
    private static var instance: StorageData = StorageData()
    
    private init() {}
    
    static func getInstance() -> StorageData{
        return instance
    }
    
    
    func categorizeStorage(_ items: [Item]) -> [ExpiryCategory: [Item]] {
        let calendar = Calendar.current
        let currentDate = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        var categorizedStorage: [ExpiryCategory: [Item]] = [
            .expired: [],
            .today: [],
            .tomorrow: [],
            .thisWeek: [],
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
            } else if calendar.isDate(expiryDate, inSameDayAs: tomorrow) {
                categorizedStorage[.tomorrow]?.append(item)
            } else if calendar.component(.weekOfYear, from: expiryDate) == calendar.component(.weekOfYear, from: currentDate) && calendar.component(.month, from: expiryDate) == calendar.component(.month, from: currentDate) && calendar.component(.year, from: expiryDate) == calendar.component(.year, from: currentDate){
                categorizedStorage[.thisWeek]?.append(item)
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

    
    
    func getExpiryCategory(for intValue: Int) -> ExpiryCategory {
        switch intValue {
        case 0:
            return .expired
        case 1:
            return .today
        case 2:
            return .thisMonth
        default:
            return .later
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