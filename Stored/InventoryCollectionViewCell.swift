import UIKit

class InventoryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var storageImage: UIImageView!
    @IBOutlet var storageName: UILabel!
    @IBOutlet var storageItemsCount: UILabel!
    
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}
