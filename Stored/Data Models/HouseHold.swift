//
//  HouseHold.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import Foundation

class Household {
    var name: String
    var code: String
    var storages : [StorageLocation]
    var userIDs : [String]
    
    // Static set to store generated IDs
    private static var generatedIDs: Set<String> = Set<String>()
    
    init(name : String, storages : [StorageLocation]) {
        self.name = name
        self.storages = storages
        self.userIDs = []
        self.code = ""
        self.code = generateUniqueID()
    }
    
    init(name : String, code : String, storages : [StorageLocation], userIds : [String]) {
        self.name = name
        self.storages = storages
        self.code = code
        self.userIDs = userIds
    }
    
    init(name: String) {
        self.name = name
        self.code = ""
        self.storages = [
            StorageLocation(name: "Pantry", items: [Item]()),
            StorageLocation(name: "Fridge", items: [Item]()),
            StorageLocation(name: "Freezer", items: [Item]()),
            StorageLocation(name: "Shelf", items: [Item]()),
            StorageLocation(name: "All", items: [Item]())
        ]
        self.userIDs = []
        self.code = generateUniqueID()
    }
    
    private func generateUniqueID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var randomString = ""
        for _ in 0..<6 {
            let randomIndex = Int(arc4random_uniform(UInt32(letters.count)))
            randomString += String(letters[letters.index(letters.startIndex, offsetBy: randomIndex)])
        }
        
        var uniqueID = "\(randomString)\(timestamp)"
        uniqueID = String(uniqueID.prefix(10))
        
        while Household.generatedIDs.contains(uniqueID) {
            uniqueID = generateUniqueID()
        }
        
        Household.generatedIDs.insert(uniqueID)
        
        return uniqueID
    }
    
    func getStorage(for storageName : String) -> StorageLocation? {
        for storage in self.storages {
            if storage.name == storageName {
                return storage
            }
        }
        return nil
    }
}



class HouseholdData{
    private init(){
    }
    private static let instance = HouseholdData()
    static func getInstance() -> HouseholdData{
        instance
    }
    
    
    var householdMembers = [User]()
    var household = Household(name: "Ashu's House")
    
    func addMember(user: User) {
        if !householdMembers.contains(where: { $0.email == user.email }) {
            householdMembers.append(user)
        }
    }

    
    func removeMember(user : User){
        if let index = self.householdMembers.firstIndex(where: { $0.email == user.email }) {
            self.householdMembers.remove(at: index)
        }
    }

}
