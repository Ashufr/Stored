import Foundation
import FirebaseDatabase

final class DatabaseManager {
    // MARK: - Properties
    
    // Tab bar controller reference
    var storedTabBarController : StoredTabBarController? {
        didSet{
            print("Assigned to DataBase")
        }
    }
    
    // Shared instance
    static let shared = DatabaseManager()
    
    // Firebase database reference
    private let database = Database.database().reference()
    var databaseHandles: [DatabaseHandle] = []

    
    // Reference to items location in the database
    private let itemsRef: DatabaseReference
    
    // MARK: - Initializers
    
    private init() {
        // Initialize a reference to the items location in the database
        itemsRef = Database.database().reference().child("items")
    }
    
    // MARK: - User Management
    
    // Function to check if a user exists
    public func userExists(with email: String, completion: @escaping (Bool) -> Void) {
        // Convert email to a safe format for use as a database key
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // Check if the user exists in the database
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // If the snapshot value is nil, the user does not exist
            guard let _ = snapshot.value as? String else {
                completion(false)
                return
            }
            
            // User exists
            completion(true)
        })
    }
    
    // Function to insert a new user into the database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        // Prepare user data to be written to the database
        let userData: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email
        ]
        
        // Insert user data into the database
        database.child("users").child(user.safeEmail).setValue(userData, withCompletionBlock: { error, _ in
            // Check for errors
            guard error == nil else {
                print("Failed to write to database:", error!.localizedDescription)
                completion(false)
                return
            }
            
            // User data inserted successfully
            print("User data inserted successfully")
            completion(true)
        })
    }

    
    // Function to edit user details in the database
    public func editUser(with user: User, completion: @escaping (Bool) -> Void) {
        // Prepare user data to be written to the database
        let userData: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email,
            "household": user.household as Any, // Store household information if available
        ]
        
        // Update user data in the database
        database.child("users").child(user.safeEmail).setValue(userData, withCompletionBlock: { error, _ in
            // Check for errors
            guard error == nil else {
                print("Failed to write to database:", error!.localizedDescription)
                completion(false)
                return
            }
            
            // User data updated successfully
            print("User data updated successfully")
            completion(true)
        })
    }

    
    // Function to retrieve user data from the database
    public func getUserFromDatabase(email: String, completion: @escaping (User?, String?) -> Void) {
        // Get the safe email from the provided email address
        let safeEmail = StorageManager.safeEmail(email: email)
        
        // Retrieve user data from the database
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with : { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                // User data not found or error occurred
                completion(nil, nil)
                print("User data not found")
                return
            }
            
            // Extract user information from userData
            guard let firstName = userData["firstName"] as? String,
                  let lastName = userData["lastName"] as? String,
                  let userEmail = userData["email"] as? String
            else {
                print("User data incomplete")
                completion(nil, nil)
                return
            }
            
            // Create a User object from the retrieved data
            let user = User(firstName: firstName, lastName: lastName, email: userEmail)
            
            // Check if the user has a household associated with them
            if let householdData = userData["household"] as? [String: Any] {
                // If yes, reload household table view (if needed) and pass household code to completion handler
                self.storedTabBarController?.householdNavigationController?.householdViewController?.householdTableView.reloadData()
                completion(user, householdData["code"] as? String)
            } else {
                // If not, indicate that the user doesn't have a house
                print("User doesn't have a household")
                completion(user, nil)
            }
        })
    }

    
    // MARK: - Household Management
    
    // Function to update household details for a user
    public func updateHousehold(for user: User, with household: Household, completion: @escaping (Bool) -> Void) {
        // Prepare the household data to be updated
        let householdData: [String: Any] = [
            "name": household.name,
            "code": household.code,
        ]
        
        // Get the safe email of the user
        let safeEmail = user.safeEmail
        
        // Update the user's household information in the database
        database.child("users").child(safeEmail).child("household").setValue(householdData) { error, _ in
            if let error = error {
                // Handle the error if updating fails
                print("Failed to update household: ", error.localizedDescription)
                completion(false)
            } else {
                // Update the user's household ID with their first and last name
                self.database.child("households").child(household.code).child("userIDs").updateChildValues([safeEmail: "\(user.firstName) \(user.lastName)"]) { error, _ in
                    if let error = error {
                        // Handle the error if adding the user to the household fails
                        print("Failed to add user to household: ", error.localizedDescription)
                        completion(false)
                    } else {
                        // Indicate successful update and perform UI updates if needed
                        print("User added to household")
                        self.storedTabBarController?.expiringNavigationController?.expiringViewController?.itemAdded()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                        completion(true)
                    }
                }
            }
        }
    }

    
    // Function to update the name of a household
    func updateHouseholdName(code: String, newName: String, completion: @escaping (Bool) -> Void) {
        // Prepare the new household data with the updated name
        let householdData: [String: Any] = [
            "name": newName,
            "code": code
        ]
        
        // Update the household name in the database
        database.child("households").child(code).updateChildValues(householdData) { error, _ in
            if let error = error {
                // Handle the error if updating fails
                print("Failed to update household name:", error.localizedDescription)
                completion(false)
            } else {
                // Indicate successful update
                print("Household name updated successfully")
                completion(true)
            }
        }
    }

    
    // Function to leave a household
    public func leaveHousehold(user: User, completion: @escaping (Bool) -> Void) {
        // Check if the user is currently part of a household
        guard let householdCode = user.household?.code else {
            print("User is not currently part of any household")
            completion(false)
            return
        }
        
        // Remove the household reference from the user's data
        database.child("users").child(user.safeEmail).child("household").removeValue { error, _ in
            if let error = error {
                print("Failed to remove household reference from user:", error.localizedDescription)
                completion(false)
            } else {
                // Remove the user from the household's userIDs
                self.database.child("households").child(householdCode).child("userIDs").child(user.safeEmail).removeValue { error, _ in
                    if let error = error {
                        print("Failed to remove user from household:", error.localizedDescription)
                        completion(false)
                    } else {
                        HouseholdData.getInstance().householdMembers = []
                        self.storedTabBarController?.householdNavigationController?.householdViewController?.householdTableView.reloadData()
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountHouseholdViewController?.accountHouseholdTableView.reloadData()
                        print("User successfully left household")
                        completion(true)
                    }
                }
            }
        }
    }


    // Function to insert a new household into the database
    public func insertHousehold(by user: User, with house: Household, completion: @escaping (String?) -> Void) {
        // Convert household storages to dictionary format
        let storagesDict: [String: [String: Any]] = house.storages.reduce(into: [:]) { result, storage in
            // Skip the storage named "All"
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
                    "imageUrl": item.imageURL?.absoluteString ?? "",
                    "userID": user.safeEmail,
                    "itemID": item.itemId ?? ""
                    // Add other item properties as needed
                ]
            }
            
            // Construct the dictionary for the storage
            let storageDict: [String: Any] = [
                "name": storage.name,
                "items": itemsDict
            ]
            
            // Add the storage dictionary to the result dictionary
            result[storage.name] = storageDict
        }
        
        // Generate a unique ID for the household
        let ref = database.child("households").childByAutoId()
        let uniqueId = ref.key ?? "NO REF"
        
        // Construct the household data dictionary
        let householdData: [String: Any] = [
            "name": house.name,
            "code": uniqueId,
            "storages": storagesDict,
            "userIDs": user.firstName
        ]
        
        // Write the household data to the database
        database.child("households").child(uniqueId).setValue(householdData) { error, _ in
            // Check for errors
            guard error == nil else {
                print("Failed to write to database")
                completion(nil)
                return
            }
            
            // Call completion handler with the unique ID
            print("Household created successfully")
            completion(uniqueId)
        }
    }

    
    // Function to get the name of a user
    public func getUserName(user: User, completion: @escaping (String?, String?) -> Void) {
        // Construct the reference to the user's data in the database
        database.child("users").child(user.safeEmail).observeSingleEvent(of: .value) { snapshot in
            // Check if the snapshot contains valid data
            guard let value = snapshot.value as? [String: Any],
                  let firstName = value["firstName"] as? String,
                  let lastName = value["lastName"] as? String else {
                // If data is not found or is invalid, call completion handler with nil values
                completion(nil, nil)
                return
            }
            
            // Call the completion handler with the user's first name and last name
            completion(firstName, lastName)
        }
    }

    
    // MARK: - Item Management
    
    
    // Function to insert an item into a storage location
    func insertItem(with item: Item, householdCode: String, storageName: String, completion: @escaping (String?) -> Void) {
        // Construct the path to the storage location for the item
        let storagePath = "\(householdCode)/storages/\(storageName)/items"
        
        // Generate a unique ID for the item
        let itemId = database.child("households").child(storagePath).childByAutoId().key ?? "id not generated"
        
        // Convert item properties to a dictionary
        let itemData: [String: Any] = [
            "name": item.name,
            "quantity": item.quantity,
            "storage": storageName,
            "dateAdded": item.dateAdded.timeIntervalSince1970,
            "expiryDate": item.expiryDate.timeIntervalSince1970,
            "imageUrl" : item.imageURL?.absoluteString ?? "",
            "userId" : item.userId,
            "itemId" : itemId
        ]
        
        // Set the item data in the database
        database.child("households").child(storagePath).child(itemId).setValue(itemData) { error, itemRef in
            // Check for errors
            guard error == nil else {
                // Handle error if occurred
                print("Failed to write item to database")
                completion(nil)
                return
            }
            
            // If successful, call the completion handler with the item ID
            completion(itemRef.key)
            
            // Notify users in the household about the item addition
            self.notifyUsersInHousehold(householdCode: householdCode)
        }
    }
    

    // Function to get an item from the database
    func getItem(householdCode : String, storage : String, withID itemID: String, completion: @escaping (Item?) -> Void) {
        // Reference to the specific item in the database
        let itemRef = database.child("households").child(householdCode).child("storages").child(storage).child("items").child(itemID)
        
        // Retrieve the item data from the database
        itemRef.observeSingleEvent(of: .value) { snapshot in
            guard let itemData = snapshot.value as? [String: Any] else {
                // Item not found or data is invalid
                print("returnn")
                completion(nil)
                return
            }
            
            // Parse item data into an Item object
            let item = self.parseItem(from: itemData)
            
            // Return the item object via completion handler
            completion(item)
        }
    }
    
    // Function to update the image URL of an item
    func updateItemImageURL(householdCode: String, storageName: String, forItemWithID itemID: String, imageURL: String, completion: @escaping (Error?) -> Void) {
        // Reference to the item in the database
        let itemRef = database.child("households").child(householdCode).child("storages").child(storageName).child("items").child(itemID)

        // Update the imageURL for the item
        itemRef.updateChildValues(["imageUrl": imageURL]) { error, _ in
            if let error = error {
                // Error occurred while updating the imageURL
                print("Error updating item image URL: \(error.localizedDescription)")
                completion(error)
            } else {
                // Item imageURL updated successfully
                print("Item image URL updated successfully")
                completion(nil)
            }
        }
    }

    
    // Function to update item details in the database
    func updateItem(householdCode: String, oldStorageName: String, for item: Item, completion: @escaping (Error?) -> Void) {
        // Ensure the item has an ID
        guard let itemId = item.itemId else {
            print("Item doesn't have an ID")
            return
        }
        
        // Check if the storage location has changed
        if oldStorageName != item.storage {
            print("Storage changed")
            // Remove the item from the old storage location
            database.child("households").child(householdCode).child("storages").child(oldStorageName).child("items").child(itemId).removeValue()
        }
        
        // Reference to the item in the database
        let itemRef = database.child("households").child(householdCode).child("storages").child(item.storage).child("items").child(itemId)
        
        // Convert item properties to dictionary
        let itemData: [String: Any] = [
            "name": item.name,
            "quantity": item.quantity,
            "storage": item.storage,
            "dateAdded": item.dateAdded.timeIntervalSince1970,
            "expiryDate": item.expiryDate.timeIntervalSince1970,
            "imageUrl": item.imageURL?.absoluteString ?? "",
            "userId": item.userId,
            "itemId": itemId
            // Add other item properties as needed
        ]
        
        // Update the item data in the database
        itemRef.setValue(itemData) { error, _ in
            if let error = error {
                // Error occurred while updating the item
                print("Error updating item: \(error.localizedDescription)")
                completion(error)
            } else {
                // Item updated successfully
                print("Item updated successfully")
                completion(nil)
            }
        }
    }

    
    // Function to delete an item from a storage location
    func deleteItem(householdCode: String, for item: Item, completion: @escaping (Error?) -> Void) {
        // Ensure the item has an ID
        guard let itemId = item.itemId else {
            print("Item doesn't have an ID")
            return
        }
        
        // Reference to the item in the database
        let itemRef = database.child("households").child(householdCode).child("storages").child(item.storage).child("items").child(itemId)
        
        // Remove the item from the database
        itemRef.removeValue { error, _ in
            // Handle any error that occurred during the removal process
            if let error = error {
                print("Error removing value:", error.localizedDescription)
                completion(error)
            } else {
                // Item removed successfully
                print("Value removed successfully")
                completion(nil)
            }
        }
    }

    
    // Function to fetch household data from the database
    func fetchHouseholdData(for householdCode: String, completion: @escaping (Household?) -> Void) {
        // Retrieve household data from the database
        database.child("households").child(householdCode).observeSingleEvent(of: .value) { snapshot in
            // Check if household data exists in the snapshot
            guard let householdData = snapshot.value as? [String: Any] else {
                // Handle case where household data is not found
                print("Household data not found")
                completion(nil)
                return
            }
            
            // Parse household data into a Household object
            if let household = self.parseHousehold(from: householdData) {
                // If parsing is successful, update UI components and call completion handler with household object
                self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                self.storedTabBarController?.expiringNavigationController?.expiringViewController?.itemAdded()
                completion(household)
            } else {
                // If parsing fails, log an error message and call completion handler with nil
                print("Failed to parse household data")
                completion(nil)
            }
        }
    }

    
    // MARK: - Observers
    
    // Function to observe changes in Household members
    func observeUsersChanges(for user: User, householdCode : String) {
        // Call observeUsersAdded function
        observeUsersAdded(for: user, householdCode: householdCode)
        
        // Call observeUsersRemoved function
        observeUsersRemoved(for: user, householdCode: householdCode)
    }
    
    // Function to observe users added in the household
    func observeUsersAdded(for user: User, householdCode : String) {
        
        // Add an observer for the "userIDs" node within the specified household
        let userIDsRef = database.child("households").child(householdCode).child("userIDs")
        userIDsRef.observe(.childAdded) { userSnapshot in
            // Extract the email of the added user from the snapshot key
            let userEmail = userSnapshot.key
            
            // Get user details from the database using the email
            self.getUserFromDatabase(email: userEmail) { addedUser, _ in
                if let addedUser = addedUser {
                    // Handle the added user
                    HouseholdData.getInstance().addMember(user : addedUser)
                    self.storedTabBarController?.householdNavigationController?.householdViewController?.householdTableView.reloadData()
                    self.storedTabBarController?.accountNavigationController?.accountViewController?.accountHouseholdViewController?.accountHouseholdTableView.reloadData()
                    print("User added to household: \(user.firstName) \(user.lastName)")
                    // You can perform any necessary actions here
                } else {
                    // Failed to retrieve details of the added user
                    print("Failed to retrieve details of the added user with email: \(userEmail)")
                }
            }
        }
    }
    
    // Function to observe users deleted in the household
    func observeUsersRemoved(for user: User, householdCode : String) {
        
        // Add an observer for the "userIDs" node within the specified household
        let userIDsRef = database.child("households").child(householdCode).child("userIDs")
        userIDsRef.observe(.childRemoved) { userSnapshot in
            // Extract the email of the removed user from the snapshot key
            let userEmail = userSnapshot.key
            
            // Get user details from the database using the email
            self.getUserFromDatabase(email: userEmail) { removedUser, _ in
                if let removedUser = removedUser {
                    // Handle the removed user
                    HouseholdData.getInstance().removeMember(user: removedUser)
                    self.storedTabBarController?.householdNavigationController?.householdViewController?.householdTableView.reloadData()
                    self.storedTabBarController?.accountNavigationController?.accountViewController?.accountHouseholdViewController?.accountHouseholdTableView.reloadData()
                    print("User removed from household: \(removedUser.firstName) \(removedUser.lastName)")
                    // You can perform any necessary actions here
                } else {
                    // Failed to retrieve details of the removed user
                    print("Failed to retrieve details of the removed user with email: \(userEmail)")
                }
            }
        }
    }


    
    // Function to observe changes in all storage locations
    func observeAllStorages(user: User, for householdCode: String) {
        // Print a message indicating which household is being observed by which user
        print("Observing for \(householdCode) by user: \(user.firstName)")
        
        // Add an observer for all storages within the specified household
        let handle = database.child("households").child(householdCode).child("storages").observe(.childAdded) { storageSnapshot in
            // Extract the name of the storage from the snapshot
            let storageName = storageSnapshot.key
            
            // Observe for items added to this storage
            self.observeItemsAdded(user: user, for: householdCode, storageName: storageName)
            
            // Observe for items updated in this storage
            self.observeItemsUpdated(user: user, for: householdCode, storageName: storageName)
            
            // Observe for items deleted from this storage
            self.observeItemsDeleted(for: householdCode, storageName: storageName)
        }
        
        // Store the database handle for future reference
        databaseHandles.append(handle)
    }

    
    // Function to observe added items in a storage location
    func observeItemsAdded(user: User, for householdCode: String, storageName: String) {
        // Add an observer for items added to the specified storage within the household
        database.child("households").child(householdCode).child("storages").child(storageName).child("items").observe(.childAdded) { itemSnapshot in
            // Extract the item ID from the snapshot
            let itemID = itemSnapshot.key
            
            // Retrieve the item from the database
            self.getItem(householdCode: householdCode, storage: storageName, withID: itemID) { item in
                if let item = item {
                    // Update local storage with the retrieved item
                    if var storage = UserData.getInstance().user?.household?.getStorage(for: item.storage), var allStorage = UserData.getInstance().user?.household?.getStorage(for: "All") {
                        storage.items.append(item)
                        allStorage.items.append(item)
                        
                        // Update UI elements to reflect the addition of the item
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.itemAdded()
                        self.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
                        self.storedTabBarController?.expiringNavigationController?.expiringViewController?.itemAdded()
                        self.storedTabBarController?.accountNavigationController?.accountViewController?.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                        print("Item added to local storage successfully")
                    } else {
                        print("Local storage not found")
                    }
                } else {
                    // Item not found or failed to retrieve
                    print("Failed to retrieve item with ID: \(itemID)")
                }
            }
        }
    }

    
    // Function to observe updated items in a storage location
    func observeItemsUpdated(user: User, for householdCode: String, storageName: String) {
        // Add an observer for items updated in the specified storage within the household
        database.child("households").child(householdCode).child("storages").child(storageName).child("items").observe(.childChanged) { itemSnapshot in
            // Extract the item ID from the snapshot
            let itemId = itemSnapshot.key
            
            // Retrieve the updated item from the database
            self.getItem(householdCode: householdCode, storage: storageName, withID: itemId) { item in
                if let item = item {
                    if var storage = UserData.getInstance().user?.household?.getStorage(for: item.storage),
                       var allStorage = UserData.getInstance().user?.household?.getStorage(for: "All") {
                        
                        // Update the item within the specific storage
                        if let index = storage.items.firstIndex(where: { $0.itemId == item.itemId }) {
                            storage.items[index] = item
                        }
                        
                        // Update the item within the "All" storage
                        if let index = allStorage.items.firstIndex(where: { $0.itemId == item.itemId }) {
                            allStorage.items[index] = item
                        }
                        
                        // Reload UI elements to reflect the updated item
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                        self.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
                        self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
                        print("Item updated in local storage successfully")
                    } else {
                        print("Local storage not found")
                    }
                } else {
                    // Item not found or failed to retrieve
                    print("Failed to retrieve item with ID: \(itemId)")
                }
            }
        }
    }

    
    // Function to observe deleted items from a storage location
    func observeItemsDeleted(for householdCode: String, storageName: String) {
        // Reference to the items in the specified storage within the household
        let itemsRef = database.child("households").child(householdCode).child("storages").child(storageName).child("items")
        
        // Add an observer for items removed (deleted) from the storage
        itemsRef.observe(.childRemoved) { itemSnapshot in
            // Extract the ID of the deleted item
            let itemId = itemSnapshot.key
            
            // Remove the item from local storage
            if var storage = UserData.getInstance().user?.household?.getStorage(for: storageName),
               var allStorage = UserData.getInstance().user?.household?.getStorage(for: "All") {
                
                // Remove the item from the specific storage
                if let index = storage.items.firstIndex(where: { $0.itemId == itemId }) {
                    storage.items.remove(at: index)
                }

                // Remove the item from the "All" storage
                if let index = allStorage.items.firstIndex(where: { $0.itemId == itemId }) {
                    allStorage.items.remove(at: index)
                }
                
                // Reload UI or perform any necessary actions to reflect the deletion
                self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryCollectionView.reloadData()
                self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryTableView.reloadData()
                self.storedTabBarController?.expiringNavigationController?.expiringViewController?.reloadTable()
                self.storedTabBarController?.inventoryNavigationController?.inventoryViewController?.inventoryStorageViewController?.itemAdded()
                
                print("Item deleted from local storage successfully")
            } else {
                print("Local storage not found")
            }
        }
    }

    
    // Function to remove previously added observers
    func removePreviousObservers() {
        // Iterate through all database handles
        for handle in databaseHandles {
            // Remove the observer associated with the handle
            database.removeObserver(withHandle: handle)
        }
        
        // Clear the handles array after removing all observers
        databaseHandles.removeAll()
    }

    
    // MARK: - Private Helper Methods
    
    // Helper function to parse household data
    private func parseHousehold(from data: [String: Any]) -> Household? {
        // Extract necessary household data from the provided dictionary
        guard let name = data["name"] as? String,
              let code = data["code"] as? String,
              let storagesData = data["storages"] as? [String: Any],
              let userIDs = data["userIDs"] as? [String : Any]
        else {
            // If essential data is missing, return nil
            print("returning")
            return nil
        }
        
        // Extract user IDs associated with the household
        var ids = [String]()
        for (userID, _) in userIDs {
            ids.append(userID)
        }
        
        // Extract items and storage locations associated with the household
        var allItems = [Item]()
        var storages: [StorageLocation] = []
        for (storageName, storageData) in storagesData {
            print(storageName)
            // Parse each storage location and its items
            if let storage = parseStorage(name : storageName, from: storageData) {
                storages.append(storage)
                // Add items from each storage to the allItems array
                for item in storage.items {
                    allItems.append(item)
                }
            }
        }
        
        // Sort storages alphabetically and append a special "All" storage containing all items
        storages.sort { $0.name > $1.name }
        storages.append(StorageLocation(name: "All", items: allItems))
        
        // Create and return a Household object with the parsed data
        return Household(name: name, code: code, storages: storages, userIds: ids)
    }

    
    // Helper function to parse storage data
    private func parseStorage(name : String, from data: Any) -> StorageLocation? {
        // Ensure that the data is in the expected format
        guard let data = data as? [String : Any] else {
            return nil
        }
        
        // Extract item data associated with the storage
        let itemsData = data["items"] as? [String: Any] ?? [String : Any]()
        var items: [Item] = []
        for itemData in itemsData {
            // Parse each item in the storage
            if let item = parseItem(from: [itemData.key : itemData.value]) {
                items.append(item)
            }
        }

        // Create a StorageLocation object with the parsed data and return it
        let storage = StorageLocation(name: name, items: items)
        return storage
    }

    
    // Helper function to parse item data
    private func parseItem(from data: [String: Any]) -> Item? {
        // Extract item properties from the data dictionary
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let storage = data["storage"] as? String,
              let dateAddedTimestamp = data["dateAdded"] as? TimeInterval,
              let expiryDateTimestamp = data["expiryDate"] as? TimeInterval,
              let imageUrl = data["imageUrl"] as? String,
              let userId = data["userId"] as? String,
              let itemId = data["itemId"] as? String
        else {
            return nil
        }
        
        // Convert timestamps to Date objects
        let dateAdded = Date(timeIntervalSince1970: dateAddedTimestamp)
        let expiryDate = Date(timeIntervalSince1970: expiryDateTimestamp)
        
        // Create and return an Item object with the parsed data
        return Item(name: name, quantity: quantity, storage: storage, dateAdded: dateAdded, expiryDate: expiryDate, imageURL: imageUrl, userId: userId, itemId: itemId)
    }

    
    // Function to notify users in a household about changes
    private func notifyUsersInHousehold(householdCode: String) {
        // ...
    }
}
