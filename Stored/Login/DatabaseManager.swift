//
//  DatabaseManager.swift
//  Stored
//
//  Created by student on 10/05/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    var storedTabBarController : StoredTabBarController?
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private let itemsRef: DatabaseReference
    
    private init() {
        // Initialize a reference to the items location in the database
        itemsRef = Database.database().reference().child("items")
    }
    
    func subscribeToItemChanges(for householdCode: String, currentUser: User, completion: @escaping (DataSnapshot, String?) -> Void) {
        let householdItemsRef = itemsRef.child(householdCode)
        
        householdItemsRef.observe(.childAdded) { snapshot, previousChildKey in
            // Call the completion handler with the snapshot and previous child key
            completion(snapshot, previousChildKey)
        }
    }
}

extension DatabaseManager {
    
    public func userExists(with email : String, completion : @escaping (Bool) -> Void){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard let _ = snapshot.value as? String else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func insertUser(with user : User, completion : @escaping (Bool) -> Void){
        database.child("users").child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName,
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                return
            }
            completion(true)
        })
    }
    
    public func updateHousehold(for email: String, with household: Household, completion: @escaping (Bool) -> Void) {
        let householdData: [String: Any] = [
            "name": household.name,
            "code": household.code,
            // Add other household properties as needed
        ]
        let safeEmail = StorageManager.safeEmail(email: email)
        
        database.child("users").child(safeEmail).child("household").setValue(householdData) { error, _ in
            if let error = error {
                print("Failed to update household:", error.localizedDescription)
                completion(false)
            } else {
                print("Household updated successfully")
                completion(true)
            }
        }
    }
    
    
    public func getUserFromDatabase(email: String, completion: @escaping (User?) -> Void) {
        let safeEmail = StorageManager.safeEmail(email: email)
        print(safeEmail)
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with : { snapshot  in
            guard let userData = snapshot.value as? [String: Any] else {
                // User data not found or error occurred
                completion(nil)
                print("returning")
                return
            }
            let firstName = userData["first_name"] as? String ?? "first"
            let lastName = userData["last_name"] as? String ?? "Last"
            let householdData = userData["household"]
            let user = User(firstName: firstName, lastName: lastName, email: email)
            
            if let householdData = householdData as? [String: Any],
               let name = householdData["name"] as? String,
               let code = householdData["code"] as? String {
                self.fetchHouseholdData(for: code) { household in
                    if let household = household {
                        user.household = household
                        DatabaseManager.shared.observeAllStorages(for: household.code)
                        print("assisgend")
                    } else {
                        print("Failed to fetch household data")
                    }
                }
            }else {
                print("no house")
            }
            
            
            
            
            // Parse the user data and create a User object
            
            
            // Call the completion handler with the user object
            completion(user)
        })
    }
    
    
    
    public func insertHousehold(by user : User, with house: Household, completion: @escaping (Bool) -> Void) {
        // Convert storages and items to dictionaries for Firebase
        let storagesDict: [String: [String: Any]] = house.storages.reduce(into: [:]) { result, storage in
            // Map the items of the current storage to dictionaries
            let itemsDict = storage.items.map { item in
                return [
                    "name": item.name,
                    "quantity": item.quantity,
                    "storage": item.storage,
                    "dateAdded": item.dateAdded.timeIntervalSince1970,
                    "expiryDate": item.expiryDate.timeIntervalSince1970,
                    "imageUrl" : item.imageURL?.absoluteString ?? "",
                    "userID" : user.safeEmail
                    // Add other item properties as needed
                ]
            }
            
            // Create a dictionary for the current storage
            let storageDict: [String: Any] = [
                "name": storage.name,
                "items": itemsDict
            ]
            
            // Add the storage dictionary to the result with the storage name as the key
            result[storage.name] = storageDict
        }
        
        
        let householdData: [String: Any] = [
            "name": house.name,
            "code": house.code,
            "storages": storagesDict
        ]
        
        database.child("households").child(house.code).setValue(householdData) { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            print("House hold created successfully")
            completion(true)
        }
    }
    
    
    public func getUserName(user: User, completion: @escaping (String?, String?) -> Void) {
        database.child("users").child(user.safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let firstName = value["first_name"] as? String,
                  let lastName = value["last_name"] as? String else {
                completion(nil, nil)
                return
            }
            completion(firstName, lastName)
        }
    }
    
    
    
    
    func fetchHouseholdData(for householdCode: String, completion: @escaping (Household?) -> Void) {
        database.child("households").child(householdCode).observeSingleEvent(of: .value) { snapshot in
            guard let householdData = snapshot.value as? [String: Any] else {
                print("Household data not found")
                completion(nil)
                return
            }
            if let household = self.parseHousehold(from: householdData) {
                completion(household)
            } else {
                print("Failed to parse household data")
                completion(nil)
            }
        }
    }
    
    // Helper function to parse household data
    private func parseHousehold(from data: [String: Any]) -> Household? {
        guard let name = data["name"] as? String,
              let code = data["code"] as? String
        else {
            return nil
        }
        if let storagesData = data["storages"] as? [[String: Any]] {
            var storages: [StorageLocation] = []
            for storageData in storagesData {
                if let storage = parseStorage(from: storageData) {
                    storages.append(storage)
                }
            }
            
            return Household(name: name, code: code, storages: storages)
        }else{
            return Household(name: name, code: code, storages: [])
        }
        
        
        
        
    }
    
    // Helper function to parse storage data
    private func parseStorage(from data: [String: Any]) -> StorageLocation? {
        guard let name = data["name"] as? String,
              let itemsData = data["items"] as? [[String: Any]] else {
            return nil
        }
        
        var items: [Item] = []
        for itemData in itemsData {
            if let item = parseItem(from: itemData) {
                items.append(item)
            }
        }
        
        return StorageLocation(name: name, items: items)
    }
    
    // Helper function to parse item data
    private func parseItem(from data: [String: Any]) -> Item? {
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let storage = data["storage"] as? String,
              let dateAddedTimestamp = data["dateAdded"] as? TimeInterval,
              let expiryDateTimestamp = data["expiryDate"] as? TimeInterval,
              let imageUrlString = data["imageUrl"] as? String, let imageUrl = URL(string: imageUrlString) else {
            return nil
        }
        
        let dateAdded = Date(timeIntervalSince1970: dateAddedTimestamp)
        let expiryDate = Date(timeIntervalSince1970: expiryDateTimestamp)
        
        // You can parse other item properties here
        
        return Item(name: name, quantity: quantity, storage: storage, expiryDate: expiryDate, dateAdded: dateAdded, imageUrl: imageUrl)
    }
    
    
    
    func insertItem(with item: Item, householdCode: String, storageName: String, completion: @escaping (Bool) -> Void) {
        
        // Convert item properties to dictionary
        let itemData: [String: Any] = [
            "name": item.name,
            "quantity": item.quantity,
            "storage": storageName,
            "dateAdded": item.dateAdded.timeIntervalSince1970,
            "expiryDate": item.expiryDate.timeIntervalSince1970,
            "imageUrl" : item.imageURL?.absoluteString ?? ""
            // Add other item properties as needed
        ]
        
       
        
        let allStoragePath = "\(householdCode)/storages/All/items"
        database.child("households").child(allStoragePath).childByAutoId().setValue(itemData) { error, _ in
            guard error == nil else {
                print("Failed to write item to database")
                completion(false)
                return
            }
            self.notifyUsersInHousehold(householdCode: householdCode)
            completion(true)
        }
        print("complellelel")
    }
    
    func observeAllStorages(for householdCode: String) {
        
        database.child("households").child(householdCode).child("storages").observe(.childAdded) { storageSnapshot in
            let storageName = storageSnapshot.key
            
            self.observeItemsAdded(for: householdCode, storageName: storageName)
        }
    }
    
    func observeItemsAdded(for householdCode: String, storageName: String) {
        database.child("households").child(householdCode).child("storages").child(storageName).child("items").observe(.childAdded) { itemSnapshot in
            // Handle item added event
            let itemID = itemSnapshot.key
            let itemData = itemSnapshot.value as? [String: Any] ?? [:]
            
            // Update UI or perform any necessary actions
            self.getItem(householdCode: householdCode, storage: storageName, withID: itemID) { item in
                if let item = item {
                    let storage = StorageData.getInstance().getStorage(for: item.storage)
                    let storageAll = StorageData.getInstance().storages[4]
                    storage.items.append(item)
                    storageAll.items.append(item)
                    self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                    self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                    self.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
                    self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
//                    print("Item retrieved:", item)
                } else {
                    // Item not found or failed to retrieve
                    print("Failed to retrieve item.")
                }
            }
//            print("New item added to \(storageName): \(itemID)")
        }
    }
    
    func getItem(householdCode : String, storage : String, withID itemID: String, completion: @escaping (Item?) -> Void) {
        
        let itemRef = database.child("households").child(householdCode).child("storages").child(storage).child("items").child(itemID)
        print(itemRef)
        // Retrieve the item data from the database
        itemRef.observeSingleEvent(of: .value) { snapshot in
            guard let itemData = snapshot.value as? [String: Any] else {
                // Item not found or data is invalid
                completion(nil)
                return
            }
            
            // Parse item data into an Item object
            let item = self.parseItem(from: itemData)
            
            // Return the item object via completion handler
            completion(item)
        }
    }
    
    private func notifyUsersInHousehold(householdCode: String) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let userSnapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for userSnapshot in userSnapshots {
                guard let userData = userSnapshot.value as? [String: Any],
                      let householdData = userData["household"] as? [String: Any],
                      let userHouseholdCode = householdData["code"] as? String,
                      userHouseholdCode == householdCode else {
                    continue // Skip users not in the same household
                }
                
                if let name = userData["first_name"] {
//                    print(name)
                }
            }
        }
    }
    
    
    
    // Function to add an item to the database
    func addItem(item: [String: Any]) {
        let newItemRef = database.child("items").childByAutoId()
        newItemRef.setValue(item)
    }
    
}
