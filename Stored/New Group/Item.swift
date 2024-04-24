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
