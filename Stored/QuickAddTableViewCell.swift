
import UIKit


class QuickAddTableViewCell: UITableViewCell {
    
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemAddButton: UIButton!
    
    @IBOutlet var minusBtn:UIButton!
    
    @IBOutlet var quantityLabel:UILabel!
    
    @IBOutlet var quantAddBtn:UIButton!
    
    @IBOutlet var extimateLabel:UILabel!
    
    @IBOutlet weak var rulerView: UIView!
    
    var isExpanded = false
    
    var showQuantityButtons = false {
        didSet {
            minusBtn.isHidden = !showQuantityButtons
            quantityLabel.isHidden = !showQuantityButtons
            quantAddBtn.isHidden = !showQuantityButtons
            extimateLabel.isHidden = !showQuantityButtons
            
            // Adjust cell's height based on showQuantityButtons
            if showQuantityButtons {
                
                itemNameLabel.numberOfLines = 1 // Set to 1 line
            } else {
                itemNameLabel.numberOfLines = 0 // Allow multiple lines
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        minusBtn.layer.cornerRadius = 10
        quantAddBtn.layer.cornerRadius = 10
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        rulerView.isHidden = false
        updateUI()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        guard sender == itemAddButton else { return }
        isExpanded = true
        updateUI()
    }
    
    // Action method for handling "-" button tap
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        guard var quantity = Int(quantityLabel.text ?? "0") else { return }
        quantity = max(0, quantity - 1)
        quantityLabel.text = "\(quantity)"
    }
    
    // Action method for handling "+" button tap in quantity
    @IBAction func addButtonQuantityTapped(_ sender: UIButton) {
        guard var quantity = Int(quantityLabel.text ?? "0") else { return }
        quantity += 1
        quantityLabel.text = "\(quantity)"
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            contentView.backgroundColor = .white // Set the background color to white
        }
    }
    

    
    
    
    private func updateUI() {
        let defaultBackgroundColor: UIColor = .white
        
        // Set background color for the labels
        let desiredColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // F2F2F7
        
        if isExpanded {
            minusBtn.isHidden = false
            quantityLabel.isHidden = false
            quantAddBtn.isHidden = false
            extimateLabel.isHidden = false
            itemAddButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            itemAddButton.tintColor = .green
            minusBtn.backgroundColor = desiredColor
            quantAddBtn.backgroundColor = desiredColor
            quantityLabel.backgroundColor = desiredColor
            
            let cornerRadius: CGFloat = 10
            minusBtn.layer.cornerRadius = cornerRadius
            quantAddBtn.layer.cornerRadius = cornerRadius
            
            let minusMaskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            let plusMaskedCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            minusBtn.layer.maskedCorners = minusMaskedCorners
            quantAddBtn.layer.maskedCorners = plusMaskedCorners
        } else {
            minusBtn.isHidden = true
            quantityLabel.isHidden = true
            quantAddBtn.isHidden = true
            extimateLabel.isHidden = true
            itemAddButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            itemAddButton.tintColor = .systemBlue
            minusBtn.backgroundColor = defaultBackgroundColor
            quantAddBtn.backgroundColor = defaultBackgroundColor
            quantityLabel.backgroundColor = defaultBackgroundColor
        }
        
        for subview in subviews {
            if let stackView = subview as? UIStackView {
                stackView.backgroundColor = isExpanded ? desiredColor : defaultBackgroundColor
                stackView.layer.cornerRadius = 0
            }
            if let label = subview as? UILabel, label == quantityLabel {
                label.backgroundColor = isExpanded ? desiredColor : defaultBackgroundColor
            }
        }
    }
    
    
}
