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
    
    var expiryDescription : String {
        let startDate = Date()
        let endDate  = expiryDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return "Expires in \(components.day ?? 0) days"
    }
}

var items = [Item(name: "Chocolate", storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 864000)), Item(name: "Chips", storage: "Shelf", expiryDate: Date(timeIntervalSinceNow: 432000)), Item(name: "Ice Cream", storage: "Freezer", expiryDate: Date(timeIntervalSinceNow: 1000000))]