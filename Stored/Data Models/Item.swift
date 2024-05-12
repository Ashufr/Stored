import Foundation
import UIKit

class Item {
    var name : String
    var quantity : Int
    var storage : String
    var dateAdded : Date
    var expiryDate : Date
    var expiryDays : Int?
    var imageURL : URL?
    var image : UIImage?
    var userId : String
    var itemId : String?
    
    
    var isExpired : Bool {
        return ItemData.getInstance().calulateDateDifference(startDate: Date(), endDate: expiryDate) < 0
    }
    var expiryDescription : String {
        let calendar = Calendar.current
        let currentDate = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let days = ItemData.getInstance().calulateDateDifference(startDate: Date(), endDate: expiryDate)
        
        if days < 0 {
            return "Expired \(days * -1) days ago"
        }else if calendar.isDate(expiryDate, inSameDayAs: currentDate) {
            return "Expires Today"
        }else if calendar.isDate(expiryDate, inSameDayAs: tomorrow) {
            return "Expires Tomorrow"
        }else {
            return "Expires in \(days) days"
        }
    }
    
    init(name: String, quantity: Int, storage: String, dateAdded: Date = Date(), expiryDate: Date, expiryDays: Int? = nil, imageURL: String? = nil, image: UIImage? = nil, userId: String = UserData.getInstance().user?.safeEmail ?? "", itemId : String? = nil) {
        self.name = name
        self.quantity = quantity
        self.storage = storage
        self.dateAdded = dateAdded
        self.expiryDate = expiryDate
        self.expiryDays = expiryDays
        self.imageURL = URL(string: imageURL ?? "")
        self.image = image
        self.userId = userId
        self.itemId = itemId
    }

    
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, dateAdded : Date, imageUrl : URL, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = dateAdded
//        self.imageURL = imageUrl
//        self.userId = userID
//    }
//    
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, imageUrl : String, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = Date()
//        self.imageURL = URL(string: imageUrl)
//        self.userId = userID
//    }
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, imageUrl : String, image : UIImage, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = Date()
//        self.imageURL = URL(string: imageUrl)
//        self.image = image
//        self.userId = userID
//    }
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, image : UIImage, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = Date()
//        self.image = image
//        self.userId = userID
//    }
//    
//    
//    
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, imageUrl : String, image : UIImage, dateAdded : Date, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = dateAdded
//        self.imageURL = URL(string: imageUrl)
//        self.image = image
//        self.userId = userID
//    }
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, image : UIImage, dateAdded : Date, userID : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.dateAdded = dateAdded
//        self.image = image
//        self.userId = userID
//    }
//    
//    
//    init(name: String, quantity: Int, storage: String, expiryDate: Date, expiryDays : Int, imageUrl : String) {
//        self.name = name
//        self.quantity = quantity
//        self.storage = storage
//        self.expiryDate = expiryDate
//        self.expiryDays = expiryDays
//        self.dateAdded = Date()
//        self.imageURL = URL(string: imageUrl)
//        self.userId = UserData.getInstance().user?.safeEmail ?? "no id"
//    }
    init(quickAddItem : Item, quantity : Int) {
        self.name = quickAddItem.name
        self.quantity = quantity
        self.storage = quickAddItem.storage
        self.expiryDate = Calendar.current.date(byAdding: .day, value: quickAddItem.expiryDays!, to: Date())!
        self.imageURL = quickAddItem.imageURL
        self.dateAdded = Date()
        self.userId = quickAddItem.userId
    }
    
}

class ItemData{
    private static var instance = ItemData();
    private init(){}
    static func getInstance() -> ItemData{
        instance
    }
    func loadImageFrom(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {return}
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: url)
                
                // Initialize UIImage from the image data
                let image = UIImage(data: imageData)
                
                // Call the completion handler on the main queue with the resulting image
                DispatchQueue.main.async {
                    completion(image)
                }
            } catch {
                // Handle errors
                print("Error loading image from URL: \(error)")
                
                // Call the completion handler with nil if there's an error
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    func calulateDateDifference(startDate : Date, endDate : Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day!
    }
    
    let quickAddItems : [Item] = [
        Item(name: "Amul milk", quantity: 1, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, expiryDays: 3, imageURL: "https://bigoffers.co.in/wp-content/uploads/2022/07/Amul-Slim-n-Trim-Milk-500ml-700x623.jpg"),
        Item(name: "Bonn Bread", quantity: 1, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, expiryDays: 7 , imageURL: "https://bonn.in/wp-content/uploads/2019/10/brown-dummy-with-sandwich-only-1.png"),
        Item(name: " Top ramen Instant Noodles", quantity: 3, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!, expiryDays: 180 , imageURL: "https://www.bigbasket.com/media/uploads/p/l/100003775_3-top-ramen-noodles-chicken.jpg"),
        Item(name: "Dawat Rice", quantity: 1, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())!, expiryDays: 730, imageURL: "https://images1.zeebiz.com/images/ZB-EN/900x1600/2023/6/12/1686555826739_1.jpg")
    ]
    
    

//    let pantryItems: [Item] = [
//        Item(name: "Dawat Rice", quantity: 7, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, imageUrl: "https://images1.zeebiz.com/images/ZB-EN/900x1600/2023/6/12/1686555826739_1.jpg"), // expiring in 3 days
//        Item(name: "Pasta", quantity: 4, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, imageUrl: "https://hips.hearstapps.com/vader-prod.s3.amazonaws.com/1580140712-barilla-1580140703.png?crop=1xw:1xh;center,top&resize=980:*"), // expiring in 5 days
//        Item(name: "Canned Beans", quantity: 2, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, imageUrl: "https://5.imimg.com/data5/OY/CG/MY-9378464/heinz-baked-beans-500x500.jpg"), // expiring in 7 days
//        Item(name: "Cereal", quantity: 1, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, imageUrl: "https://hips.hearstapps.com/vader-prod.s3.amazonaws.com/1682445551-cocoa-puffs-644814e84bc6d.jpg?crop=1xw:1xh;center,top&resize=980:*"), // expiring in 10 days
//        Item(name: "Flour", quantity: 6, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, imageUrl: "https://assetscdn1.paytm.com/images/catalog/product/F/FA/FASAASHIRVAAD-SBIGB9858321E98F92E/1561493103862_0.jpg"), // expiring in 15 days
//        Item(name: "Sugar", quantity: 9, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, imageUrl: "https://asset20.ckassets.com/blog/wp-content/uploads/sites/5/2022/01/1-14-1024x512.jpg"), // expiring in 20 days
//        Item(name: "Salt", quantity: 8, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 12, to: Date())!, imageUrl: "https://asset20.ckassets.com/blog/wp-content/uploads/sites/5/2021/12/2-6-1024x512.jpg"), // expiring in 25 days
//        Item(name: "Olive Oil", quantity: 3, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNBO4woU7lejkXRTU-6M3MtVVQKXzIBxLhsw&usqp=CAU"), // expiring in 30 days
//        Item(name: "Canned Soup", quantity: 1, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 35, to: Date())!, imageUrl: "https://www.eatthis.com/wp-content/uploads/sites/4/2019/01/wolfgang-puck-organic-minestrone-soup.jpg"), // expiring in 35 days
//        Item(name: "Dried Beans", quantity: 5, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!, imageUrl: "https://i5.walmartimages.com/asr/833cfd65-1dc5-4c19-9ad6-8e8d9b702e0d.ee6348c349840730d61b3e86b7a3a1cb.jpeg?odnHeight=320&odnWidth=320&odnBg=FFFFFF"), // expiring in 40 days
//        Item(name: "Peanut Butter", quantity: 2, storage: "Pantry", expiryDate: Calendar.current.date(byAdding: .day, value: 65, to: Date())!, imageUrl: "https://www.eatthis.com/wp-content/uploads/sites/4/2019/10/jif-creamy-peanut-butter.jpg") // expiring in 45 days
//    ]
//
//    let fridgeItems: [Item] = [
//        Item(name: "Milk", quantity: 4, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, imageUrl: "https://bsmedia.business-standard.com/_media/bs/img/article/2020-11/18/full/20201118172514.jpg"), // expiring in 2 days
//        Item(name: "Cheese", quantity: 6, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, imageUrl: "https://asset20.ckassets.com/blog/wp-content/uploads/sites/5/2022/01/Britannia-1024x512.jpg"), // expiring in 3 days
//        Item(name: "Greek Yogurt", quantity: 3, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, imageUrl: "https://i0.wp.com/img.paisawapas.com/ovz3vew9pw/2023/03/30142428/greek-yogurt-brands-in-india.jpg?resize=1000%2C1000&ssl=1"), // expiring in 4 days
//        Item(name: "Eggs", quantity: 5, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, imageUrl: "https://m.media-amazon.com/images/I/71imQYH-YFL.jpg"), // expiring in 5 days
//        Item(name: "Butter", quantity: 2, storage: "Fridge", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, imageUrl: "https://asset20.ckassets.com/blog/wp-content/uploads/sites/5/2022/01/1-4-1024x512.jpg") // expiring in 6 days
//    ]
//
//    let freezerItems: [Item] = [
//        Item(name: "Frozen Vegetables", quantity: 8, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, imageUrl: "https://target.scene7.com/is/image/Target/GUEST_904cc589-f061-418d-a94a-9bb5b39a9e28?qlt=65&fmt=pjpeg&hei=350&wid=350"), // expiring in 3 days
//        Item(name: "Ice Cream", quantity: 1, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, imageUrl: "https://happycredit.in/cloudinary_opt/blog/opt-5bzf7.webp"), // expiring in 5 days
//        Item(name: "Frozen Pizza", quantity: 3, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, imageUrl: "https://hips.hearstapps.com/vader-prod.s3.amazonaws.com/1552331318-celeste-pepperoni-1552331297.jpg?crop=1xw:1xh;center,top&resize=980:*"), // expiring in 7 days
//        Item(name: "Frozen Chicken", quantity: 4, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, imageUrl: "https://maplesfood.com/wp-content/uploads/2020/11/chicken-Breast-300x300.jpg"), // expiring in 10 days
//        Item(name: "Frozen Fish", quantity: 2, storage: "Freezer", expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, imageUrl: "https://maplesfood.com/wp-content/uploads/2020/11/Ct-Tilapia-1kg-2-300x300.jpg") // expiring in 15 days
//    ]
//
//    let shelfItems: [Item] = [
//        Item(name: "Lays Chips", quantity: 6, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, imageUrl: "https://images-cdn.ubuy.co.in/6402fbf460289a7e290df983-lays-potato-chips-classic-8-oz.jpg"), // expiring in 3 days
//        Item(name: "Cookies", quantity: 4, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, imageUrl: "https://lh3.googleusercontent.com/fxOEsXtkH0MExwnFg4wDJzHgDQoof_U-BV5sLVfoRSj48HCZYOaN8wXx6JQvIK8NfW3NBxZsxmDKy1BfXETkzs9NmT_QKGZhWSjul2GtG-Tq8ixHj74hm_rUiFKbX193cRrFrerGCEr2QKGvr7iEL1o"), // expiring in 4 days
//        Item(name: "Crackers", quantity: 3, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, imageUrl: "https://m.media-amazon.com/images/I/51IboHH1MYL._AC_UF1000,1000_QL80_DpWeblab_.jpg"), // expiring in 5 days
//        Item(name: "Pretzels", quantity: 2, storage: "Shelf", expiryDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, imageUrl: "https://hips.hearstapps.com/bpc.h-cdn.co/assets/17/12/480x480/square-1490294175-rold-gold-tiny-twists-pretzels.jpg?resize=980:*") // expiring in 6 days
//    ]

}
