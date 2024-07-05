import UIKit

class CalendarViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var viewModel: ViewModel
    
    private var dataSource: DataSource!
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error: could not initialize CalendarViewController without ToDoItemsStore")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        title = "Мои дела" 
        navigationItem.largeTitleDisplayMode = .never
        
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
        
        for (section, rows) in viewModel.sections {
            snapshot.appendSections([section])
            snapshot.appendItems(rows, toSection: section)
        }
        
        dataSource.apply(snapshot)
    }
    
    private func dateLabelCellRegistration(cell: DateLabelCell, indexPath: IndexPath, row: Row) {
        guard case .date(let date) = row else { return }
        
        if let date = date {
            cell.text = date.dayMonthFormatted
                .components(separatedBy: .whitespaces)
                .joined(separator: "\n")
            
            if viewModel.selectedDate == row {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        } else {
            cell.text = "Другое"
        }
    }
    
    private func listCellRegistration(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        guard case .toDoItem(let toDoItem) = row else { return }
        
        let attributedText = NSAttributedString(
            string: toDoItem.text,
            attributes: toDoItem.isCompleted ? [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.secondaryLabel
            ] : [:]
        )
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.attributedText = attributedText
        contentConfiguration.textProperties.numberOfLines = 3
        cell.contentConfiguration = contentConfiguration
    }
    
    private func headerRegistrationHandler(supplementaryView: UICollectionViewListCell, elementKind: String, indexPath: IndexPath) {
        let section = dataSource.sectionIdentifier(for: indexPath.section) ?? .other
        
        let text: String? = switch section {
        case .dates:
            nil
        case .toDoItems(let date):
            date.dayMonthFormatted
        case .other:
            "Другое"
        }
        
        var configuration = supplementaryView.defaultContentConfiguration()
        configuration.text = text
        supplementaryView.contentConfiguration = configuration
    }
    
    private func createDataSource() -> DataSource {
        let listCellRegistration = UICollectionView.CellRegistration(handler: listCellRegistration)
        let dateLabelCellRegistration = UICollectionView.CellRegistration(handler: dateLabelCellRegistration)
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader, handler: headerRegistrationHandler)
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch indexPath.section {
            case 0:
                // Dates section.
                return collectionView.dequeueConfiguredReusableCell(using: dateLabelCellRegistration, for: indexPath, item: itemIdentifier)
            default:
                // List sections.
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        return dataSource
    }
    
    private static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0:
                // Dates section.
                Self.createDatesSection()
            default:
                // List sections.
                Self.createListSection(environment: environment)
            }
        }
    }
    
    private static func createDatesSection() -> NSCollectionLayoutSection {
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
    
    private static func createListSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.backgroundColor = UIColor(AppColors.backPrimary)
        
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        
        return section
    }
}
