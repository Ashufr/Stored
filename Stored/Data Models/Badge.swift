//
//  Badge.swift
//  Stored
//
//  Created by student on 04/05/24.
//

import Foundation
import UIKit

struct Badge{
    let name : String
    let image : UIImage
    let dateEarned : Date
    
    init(name: String, image: UIImage, dateEarned: Date) {
        self.name = name
        self.image = image
        self.dateEarned = dateEarned
    }
}

class BadgeData{
    
    private init(){}
    private static var insatnce : BadgeData = BadgeData()
    
    static func getInstance() -> BadgeData {
        insatnce
    }
    let days50Badge = Badge(name: "50 Days Badge", image: UIImage(named: "Badge 50 Days")!, dateEarned: Date())
    let days100Badge = Badge(name: "100 Days Badge", image: UIImage(named: "Badge 100 Days")!, dateEarned: Date())
    let januaryBadge = Badge(name: "January Badge", image: UIImage(named: "Badge 1 January")!, dateEarned: Calendar.current.date(bySetting: .month, value: 2, of: Date())!.addingTimeInterval(-1))
    let februaryBadge = Badge(name: "February Badge", image: UIImage(named: "Badge 2 February")!, dateEarned: Calendar.current.date(bySetting: .month, value: 3, of: Date())!.addingTimeInterval(-1))
    let marchBadge = Badge(name: "March Badge", image: UIImage(named: "Badge 3 March")!, dateEarned: Calendar.current.date(bySetting: .month, value: 4, of: Date())!.addingTimeInterval(-1))
    let aprilBadge = Badge(name: "April Badge", image: UIImage(named: "Badge 4 April")!, dateEarned: Calendar.current.date(bySetting: .month, value: 5, of: Date())!.addingTimeInterval(-1))
    let mayBadge = Badge(name: "May Badge", image: UIImage(named: "Badge 5 May")!, dateEarned: Calendar.current.date(bySetting: .month, value: 6, of: Date())!.addingTimeInterval(-1))
    let juneBadge = Badge(name: "June Badge", image: UIImage(named: "Badge 6 June")!, dateEarned: Calendar.current.date(bySetting: .month, value: 7, of: Date())!.addingTimeInterval(-1))
    let julyBadge = Badge(name: "July Badge", image: UIImage(named: "Badge 7 July")!, dateEarned: Calendar.current.date(bySetting: .month, value: 8, of: Date())!.addingTimeInterval(-1))
    let augustBadge = Badge(name: "August Badge", image: UIImage(named: "Badge 8 August")!, dateEarned: Calendar.current.date(bySetting: .month, value: 9, of: Date())!.addingTimeInterval(-1))
    let septemberBadge = Badge(name: "September Badge", image: UIImage(named: "Badge 9 September")!, dateEarned: Calendar.current.date(bySetting: .month, value: 10, of: Date())!.addingTimeInterval(-1))
    let octoberBadge = Badge(name: "October Badge", image: UIImage(named: "Badge 10 October")!, dateEarned: Calendar.current.date(bySetting: .month, value: 11, of: Date())!.addingTimeInterval(-1))
    let novemberBadge = Badge(name: "November Badge", image: UIImage(named: "Badge 11 November")!, dateEarned: Calendar.current.date(bySetting: .month, value: 12, of: Date())!.addingTimeInterval(-1))

}
