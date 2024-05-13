import UIKit

class AccountHouseholdCodeTableViewCell: UITableViewCell {

    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var copySymbolLabel: UILabel! // Change to UILabel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        copySymbolLabel.textColor = .darkGray
        // Add tap gesture recognizer to the cell's content view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        contentView.addGestureRecognizer(tapGesture)
        
        // Set the clipboard symbol from SF Symbols
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "doc.on.doc")?.withTintColor(.darkGray)
                let attributedString = NSMutableAttributedString(attachment: imageAttachment)
                copySymbolLabel.attributedText = attributedString
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Copy the label text to the pasteboard
        UIPasteboard.general.string = codeLabel.text
        
        // Change copy symbol to "Copied"
        copySymbolLabel.text = "Copied"
        
    
    }

}
