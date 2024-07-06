import UIKit

class DateLabelCell: UICollectionViewCell {
    var text: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = DateLabelContentView.BackgroundConfiguration.configuration(for: state)
        
        var content = DateLabelContentView.Configuration()
        content.text = text ?? ""
        contentConfiguration = content
    }
}
