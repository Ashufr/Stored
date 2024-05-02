//
//  HouseHold.swift
//  Stored
//
//  Created by student on 02/05/24.
//

import Foundation

class Household{
    var name : String
    var members : [User] = []
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, by member : User) {
        self.name = name
        self.members.append(member)
    }
}

class HouseholdData{
    private init(){}
    private static let instance = HouseholdData()
    static func getInstance() -> HouseholdData{
        instance
    }
    
    var household = Household(name: "Olivia's House")
}
