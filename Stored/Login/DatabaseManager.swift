//
//  DatabaseManager.swift
//  Stored
//
//  Created by student on 10/05/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    var storedTabBarController : StoredTabBarController? {
        didSet{
            print("Assigned to DataBase")
        }
    }
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    var databaseHandles: [DatabaseHandle] = []
    
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
    
    public func updateHousehold(for user: User, with household: Household, completion: @escaping (Bool) -> Void) {
        let householdData: [String: Any] = [
            "name": household.name,
            "code": household.code,
        ]
        let safeEmail = user.safeEmail
        
        database.child("users").child(safeEmail).child("household").setValue(householdData) { error, _ in
            if let error = error {
                print("Failed to update household : ", error.localizedDescription)
                completion(false)
            } else {
                self.database.child("households").child(household.code).child("userIDs").updateChildValues([safeEmail :"\( user.firstName) \(user.lastName)"]) { error,_ in
                    if let error = error {
                        print("Failed to add user to household : ", error.localizedDescription)
                        completion(false)
                    }
                    else{
                        print("User added to household")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func updateHouseholdName(code: String, newName: String, completion: @escaping (Bool) -> Void) {
        let householdData: [String: Any] = [
            "name": newName,
            "code" : code,
            
        ]
        
        database.child("households").child(code).updateChildValues(householdData) { error, _ in
            if let error = error {
                print("Failed to update household name:", error.localizedDescription)
                completion(false)
            } else {
                print("Household name updated successfully")
                completion(true)
            }
        }
    }


    
    public func getUserFromDatabase(email: String, completion: @escaping (User?, String?) -> Void) {
        let safeEmail = StorageManager.safeEmail(email: email)
        print(safeEmail)
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with : { snapshot  in
            guard let userData = snapshot.value as? [String: Any] else {
                // User data not found or error occurred
                completion(nil, nil)
                print("returning")
                return
            }
            guard let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String
            else{
                print("user data not found")
                completion(nil,nil)
                return
            }
            let user = User(firstName: firstName, lastName: lastName, email: email)
            if let householdData = userData["household"] as? [String: Any] {
                completion(user, householdData["code"] as? String )
            }else{
                print("User doesn't have a house")
                completion(user, nil)
            }
            
        })
    }
    
    public func leaveHousehold(user: User, completion: @escaping (Bool) -> Void) {
        guard let householdCode = user.household?.code else{
            print("User already is not a part of any household")
            completion(false)
            return
        }
        database.child("users").child(user.safeEmail).child("household").removeValue { error, _ in
            if let error = error {
                print("Couldn't leave household:", error.localizedDescription)
                completion(false)
            } else {
                self.database.child("household").child(householdCode).child("userIDs").child(user.safeEmail).removeValue { error,_  in
                    if let error = error {
                        print("Couldn't delete user from  household:", error.localizedDescription)
                        completion(false)
                    }else {
                        print("Household left successfully")
                        completion(true)
                    }
                }
                
            }
        }
    }

    public func insertHousehold(by user : User, with house: Household, completion: @escaping (Bool) -> Void) {
        // Convert storages and items to dictionaries for Firebase
        let storagesDict: [String: [String: Any]] = house.storages.reduce(into: [:]) { result, storage in
            if storage.name == "All" {
                    return
            }
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
            
            let storageDict: [String: Any] = [
                "name": storage.name,
                "items": itemsDict
            ]
            
            result[storage.name] = storageDict
        }
        
        let householdData: [String: Any] = [
            "name": house.name,
            "code": house.code,
            "storages": storagesDict,
            "userIDs" : user.firstName
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
              let code = data["code"] as? String,
              let storagesData = data["storages"] as? [String: Any],
              let userIDs = data["userIDs"] as? [String : Any]
        else {
            print("returning")
            return nil
        }
        var ids = [String]()
        for (userID, userName) in userIDs {
            ids.append(userID)
        }
        print(storagesData)
        var allItems = [Item]()
        var storages: [StorageLocation] = []
        for (storageName, storageData) in storagesData {
            print(storageName)
            if let storage = parseStorage(name : storageName, from: storageData) {
                storages.append(storage)
                for item in storage.items {
                    allItems.append(item)
                }
            }
        }
        storages.sort { $0.name > $1.name }
        storages.append(StorageLocation(name: "All", items: allItems))
        return Household(name: name, code: code, storages: storages, userIds: ids)
    }
    
    // Helper function to parse storage dxata
    private func parseStorage(name : String, from data: Any) -> StorageLocation? {
        guard let data = data as? [String : Any] else {
            return nil
        }
        let itemsData = data["items"] as? [String: Any] ?? [String : Any]()
        var items: [Item] = []
        for itemData in itemsData {
            if let item = parseItem(from: [itemData.key : itemData.value]) {
                items.append(item)
            }
        }
    
        let storage = StorageLocation(name: name, items: items)
        return storage
    }
    
    // Helper function to parse item data
    private func parseItem(from data: [String: Any]) -> Item? {
//        print(data["userId"])
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let storage = data["storage"] as? String,
              let dateAddedTimestamp = data["dateAdded"] as? TimeInterval,
              let expiryDateTimestamp = data["expiryDate"] as? TimeInterval,
              let imageUrl = data["imageUrl"] as? String,
              let userId = data["userId"] as? String
        else {
            return nil
        }
        
        let dateAdded = Date(timeIntervalSince1970: dateAddedTimestamp)
        let expiryDate = Date(timeIntervalSince1970: expiryDateTimestamp)
        
        // You can parse other item properties here
        
        return Item(name: name, quantity: quantity, storage: storage, dateAdded: dateAdded, expiryDate: expiryDate, imageURL: imageUrl, userId: userId)
    }
    
    
    
    func insertItem(with item: Item, householdCode: String, storageName: String, completion: @escaping (Bool) -> Void) {
        
        // Convert item properties to dictionary
        let itemData: [String: Any] = [
            "name": item.name,
            "quantity": item.quantity,
            "storage": storageName,
            "dateAdded": item.dateAdded.timeIntervalSince1970,
            "expiryDate": item.expiryDate.timeIntervalSince1970,
            "imageUrl" : item.imageURL?.absoluteString ?? "",
            "userId" : item.userId
            // Add other item properties as needed
        ]
//        var insertionError : (any Error)?
        let storagePath = "\(householdCode)/storages/\(storageName)/items"
        database.child("households").child(storagePath).childByAutoId().setValue(itemData) { error, _ in
            guard error == nil else {
                print("Failed to write item to database")
                completion(false)
//                insertionError = error
                return
            }
            completion(true)
            self.notifyUsersInHousehold(householdCode: householdCode)
        }
    
       
    }
    
    func observeAllStorages(user : User, for householdCode: String) {
        print("Observing for \(householdCode) by user : \(user.firstName)")
        let handle = database.child("households").child(householdCode).child("storages").observe(.childAdded) { storageSnapshot in
            let storageName = storageSnapshot.key
            
            self.observeItemsAdded(user : user, for: householdCode, storageName: storageName)
        }
        
        databaseHandles.append(handle)
    }
    
    func observeItemsAdded(user : User, for householdCode: String, storageName: String) {
        database.child("households").child(householdCode).child("storages").child(storageName).child("items").observe(.childAdded) { itemSnapshot in
            // Handle item added event
            let itemID = itemSnapshot.key
            
            
            // Update UI or perform any necessary actions
            self.getItem(householdCode: householdCode, storage: storageName, withID: itemID) { item in
                if let item = item {
                    
                    if var storage = UserData.getInstance().user?.household?.getStorage(for: item.storage), var allStorage = UserData.getInstance().user?.household?.getStorage(for: "All") {
                        
                        storage.items.append(item)
                        allStorage.items.append(item)
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                        self.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
                        print("Item added to local storage successfully")
                    }else{
                        print("Local Storage not found")
                    }
                    
//                    print("Item retrieved:", item)
                } else {
                    // Item not found or failed to retrieve
                    print(itemID)
                    
                    print("Failed to retrieve item.")
                }
            }
//            print("New item added to \(storageName): \(itemID)")
        }
    }
    
    func removePreviousObservers() {
        for handle in databaseHandles {
            database.removeObserver(withHandle: handle)
        }
        // Clear the handles array
        databaseHandles.removeAll()
    }
    
    func getItem(householdCode : String, storage : String, withID itemID: String, completion: @escaping (Item?) -> Void) {
        
        let itemRef = database.child("households").child(householdCode).child("storages").child(storage).child("items").child(itemID)
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
