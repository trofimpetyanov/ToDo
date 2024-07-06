import UIKit

class CalendarDatesViewController: UICollectionViewController {
    
    var viewModel: ViewModel
    
    var dataSource: DataSource!
    
    weak var delegate: CalendarContainerViewControllerDelegate?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if case .date(let date) = viewModel.rows.first {
            selectDate(date)
        } else {
            selectDate(nil)
        }
    }
    
    func selectDate(_ date: Date?) {
        guard let rowIndex = viewModel.rows.firstIndex(where: { row in
            switch (row, date) {
            case (.date(let rowDate), date):
                return date == rowDate
            case (.other, nil):
                return true
            default:
                return false
            }
        })
        else { return }
        
        let indexPath = IndexPath(row: rowIndex, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case .date(let date) = viewModel.rows[indexPath.row] {
            delegate?.didSelectDate(self, date: date)
            selectDate(date)
        } else {
            delegate?.didSelectDate(self, date: nil)
            selectDate(nil)
        }
    }
    
    private func setup() {
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.backgroundColor = UIColor(AppColors.backPrimary)
        collectionView.isScrollEnabled = false
        
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.rows, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    private func cellRegistrationHandler(cell: DateLabelCell, indexPath: IndexPath, row: Row) {
        switch row {
        case .date(let date):
            cell.text = date.dayMonthFormatted
                .components(separatedBy: .whitespaces)
                .joined(separator: "\n")
        case .other:
            cell.text = "Другое"
        }
    }
    
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        return dataSource
    }
    
    private static func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let spacing: CGFloat = 8
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.16), heightDimension: .fractionalWidth(0.16))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: spacing,
                leading: spacing * 2,
                bottom: spacing,
                trailing: spacing * 2
            )
            
            return section
        }
        
        return layout
    }
}
