import UIKit

class ColorAccessoryView: UIView {
    
    var color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .init(x: 0, y: 0, width: 16, height: 16))
        
        setup()
    }
    
    private func setup() {
        backgroundColor = color
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        
        layer.cornerRadius = 8
        layer.shadowOpacity = 0.32
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
