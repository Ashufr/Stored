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
    
    // Static set to store generated IDs
    private static var generatedIDs: Set<String> = Set<String>()
    
    init(name: String) {
        self.name = name
        self.code = ""
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
}



class HouseholdData{
    private init(){
    }
    private static let instance = HouseholdData()
    static func getInstance() -> HouseholdData{
        instance
    }
    
    var household = Household(name: "Ashu's House")
}
