import UIKit

class DateLabelsHeader: UICollectionReusableView {
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView()
        collectionView.backgroundColor = UIColor(AppColors.backPrimary)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }
    
    private func setup() {
        
    }
}
