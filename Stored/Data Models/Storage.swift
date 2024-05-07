import Foundation

class Storage {
    var mid : String?
    var name : String
    var items : [Item]
    
    var count : Int {
        items.count
    }
    
    private static var allInstances = [Storage]()
    
//    static var all: Storage {
//        var allItems = [Item]()
//        var itemIdentifierSet = Set<String>()
//        
//        // Aggregate items from all storage instances
//        for storageInstance in allInstances {
//            for item in storageInstance.items {
//                // Check if the item identifier has alrea   dy been added
//                if !itemIdentifierSet.contains(item.name) {
//                    allItems.append(item)
//                    itemIdentifierSet.insert(item.name)
//                }
//            }
//        }
//        
//        return Storage(name: "All", items: allItems)
//    }
    
    init(name: String, items: [Item]) {
        self.name = name
        self.items = items
        Storage.allInstances.append(self)
    }
    init(mid: String, name: String, items: [Item]) {
        self.mid = mid
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
        Storage(name: "Pantry", items: []),
        Storage(name: "Fridge", items: []),
        Storage(name: "Freezer", items: []),
        Storage(name: "Shelf", items: []),
        Storage(name: "All", items: [])
    ]
    
    private static var instance: StorageData = StorageData()
    
    private init() {}
    
    static func getInstance() -> StorageData{
        return instance
    }
    
    
    func categorizeStorageItems(_ items: [Item]) -> [ExpiryCategory: [Item]] {
        let calendar = Calendar.current
        let currentDate = Date()
        
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
        
        let weekdayComponent = calendar.component(.weekday, from: currentDate)
            
            let daysToSubtract = (7 - weekdayComponent)
            var dateComponents = DateComponents()
            dateComponents.day = daysToSubtract

        var categorizedStorage: [ExpiryCategory: [Item]] = [
            .today: [],
            .tomorrow: [],
            .thisWeek: [],
        ]
        
        for item in items {
            let expiryDate = item.expiryDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let expiryNumber = Int(dateFormatter.string(from: expiryDate))!
            let currentNumber = Int(dateFormatter.string(from: currentDate))!
            let tomorroNumber = currentNumber + 1
            let weekNumber = Int(dateFormatter.string(from: calendar.date(byAdding: dateComponents, to: currentDate)!))!
            
            if expiryNumber == currentNumber {
                categorizedStorage[.today]?.append(item)
            } else if expiryNumber == tomorroNumber {
                categorizedStorage[.tomorrow]?.append(item)
            } else if expiryNumber <= weekNumber && expiryNumber > tomorroNumber{
                categorizedStorage[.thisWeek]?.append(item)
            }
        }
        
        for (category, items) in categorizedStorage {
            categorizedStorage[category] = items.sorted(by: { $0.expiryNumber < $1.expiryNumber })
        }
        return categorizedStorage
    }

    func getStorage(for storage : String) -> Storage {
        switch storage {
        case "Pantry":
            return storages[0]
        case "Fridge":
            return storages[1]
        case "Freezer":
            return storages[2]
        case "Shelf":
            return storages[3]
        default:
            return Storage(name: "", items: [])
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
    
    
    func createItem(item: Item, storageId: String, allStorageId: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "https://ios-backend.vercel.app/api/households/6638d09be5879d3285847710/storage/add") else {
            completion(nil) // Provide appropriate error handling
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody: [String: Any] = [
            "storageId": storageId,
            "allStorageId": allStorageId,
            "item": [
                "name": item.name,
                "quantity": item.quantity,
                "storage": item.storage,
                "expiryDate": ISO8601DateFormatter().string(from: item.expiryDate),
                "imageUrl": item.imageURL?.absoluteString ?? ""
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(error)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            // Handle response data if needed
            
            completion(nil) // Completion without error if everything succeeds
        }
        
        let timeoutInterval: TimeInterval = 5
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        task.resume()
        
        // Wait for the specified timeout interval
        let timeoutResult = dispatchGroup.wait(timeout: DispatchTime.now() + timeoutInterval)
        if timeoutResult == .timedOut {
            task.cancel()
            let timeoutError = NSError(domain: "TimeoutError", code: -1, userInfo: [NSLocalizedDescriptionKey: "The request timed out"])
            completion(timeoutError)
        }
    }

    
}
