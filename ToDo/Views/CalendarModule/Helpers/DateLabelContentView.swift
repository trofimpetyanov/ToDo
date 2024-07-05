import UIKit

class DateLabelContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration, Hashable {
        var text: String = ""

        func makeContentView() -> UIView & UIContentView {
            return DateLabelContentView(configuration: self)
        }
        
        func updated(for state: any UIConfigurationState) -> DateLabelContentView.Configuration {
            return self
        }
    }
    
    struct BackgroundConfiguration {
        static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
            var background = UIBackgroundConfiguration.clear()
            background.cornerRadius = 8
            
            if state.isHighlighted || state.isSelected {
                background.backgroundColor = .black.withAlphaComponent(0.08)
                background.strokeColor = .black.withAlphaComponent(0.16)
                background.strokeWidth = 2
            }
            
            return background
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfiguration = newValue as? Configuration else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    private var appliedConfiguration: Configuration!

    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }

    init(configuration: Configuration) {
        super.init(frame: .zero)
        
        layoutViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutViews() {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
    
    private func apply(configuration: Configuration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration
        
        label.text = configuration.text
    }
}
