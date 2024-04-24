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
    
    
    var isExpired : Bool {
        calulateDateDifference(startDate: Date(), endDate: expiryDate) < 0
    }
    var expiryDescription : String {
        let days = calulateDateDifference(startDate: Date(), endDate: expiryDate)
        if days > 0{
            return "Expires in \(days) days"
        }else{
            return "Expired \(days * -1) days ago"
        }
    }
    
}

func calulateDateDifference(startDate : Date, endDate : Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: startDate, to: endDate)
    return components.day!
}

var items = [Item(name: "Chocolate", storage: "Fridge", expiryDate: Date(timeIntervalSinceNow: 864000)), Item(name: "Chips", storage: "Shelf", expiryDate: Date(timeIntervalSinceNow: 432000)), Item(name: "Ice Cream", storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)]
