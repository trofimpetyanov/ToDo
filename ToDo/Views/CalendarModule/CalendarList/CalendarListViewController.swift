import UIKit
import SwiftUI
import LoggerPackage

class CalendarListViewController: UICollectionViewController {
    
    var viewModel: ViewModel
    
    var dataSource: DataSource!
    
    weak var delegate: CalendarContainerViewControllerDelegate?
    
    private var isScrolling = false
    private var displayedSectionIndices = [Int]()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: .init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error: could not initialize CalendarViewController without ToDoItemsStore")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Logger.logInfo("CalendarListViewController did appear.")
        
        scrollToDate(dataSource.snapshot().itemIdentifiers.first?.dueDate, animated: false)
        displayedSectionIndices = collectionView.indexPathsForVisibleItems.sorted().map { $0.section }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        
        if let firstVisibleIndexPath = visibleIndexPaths.first,
           let section = dataSource.sectionIdentifier(for: firstVisibleIndexPath.section) {
            let sectionIndex = firstVisibleIndexPath.section
            
            if !displayedSectionIndices.contains(sectionIndex) ||
                displayedSectionIndices[0] != sectionIndex && !isScrolling {
                
                displayedSectionIndices = visibleIndexPaths.map { $0.section }.sorted()
                
                switch section {
                case .toDoItems(for: let date):
                    delegate?.didScrollThroughDateSection(self, date: date)
                    
                    Logger.logVerbose("Scrolled through section with date: \(date.debugDescription).")
                case .other:
                    delegate?.didScrollThroughDateSection(self, date: nil)
                    
                    Logger.logVerbose("Scrolled through 'Other' section.")
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        delegate?.didSelectToDoItem(self, at: indexPath)
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        
        for (section, rows) in viewModel.sections.sorted(by: { $0.key < $1.key }) {
            snapshot.appendSections([section])
            snapshot.appendItems(rows, toSection: section)
        }
        
        dataSource.apply(snapshot)
    }
    
    func scrollToDate(_ date: Date?, animated: Bool = true) {
        var sectionIndex = viewModel.sections.count - 1
        var rowsNumber = 0
        
        for (index, (section, rows)) in viewModel.sections.sorted(by: { $0.key < $1.key }).enumerated() {
            if case .toDoItems(for: let toDoItemDate) = section, date == toDoItemDate {
                sectionIndex = index
                rowsNumber = rows.count
                
                break
            }
        }
        
        guard rowsNumber > 0 else { return }
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        
        isScrolling = true
        collectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
        
        // So it does not deselects the selected date while scrolling in `scrollViewDidScroll`.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isScrolling = false
        }
        
        Logger.logVerbose("Scrolled to date: \(date.debugDescription), animated: \(animated ? "true" : "false").")
    }
    
    private func setup() {
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 64, right: 0)
        
        title = "Мои дела"
        navigationItem.largeTitleDisplayMode = .never
        
        updateSnapshot()
        
        Logger.logVerbose("CalendarListViewController setup completed.")
    }
    
    private func swipeAction(for indexPath: IndexPath, isCompleted: Bool) -> UISwipeActionsConfiguration {
        guard let toDoItem = self.dataSource.itemIdentifier(for: indexPath)
        else { return UISwipeActionsConfiguration() }
        
        let actionHandler: UIContextualAction.Handler = { _, _, completion in
            self.delegate?.didCompleteToDoItem(self, toDoItem: toDoItem, isCompleted: isCompleted)
            
            completion(true)
        }
        
        let action = UIContextualAction(
            style: .normal,
            title: isCompleted ? "Выполнить" : "Отменить выполнение",
            handler: actionHandler)
        action.image = UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "circle.fill")
        action.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let attributedText = NSAttributedString(
            string: row.text,
            attributes: row.isCompleted ? [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.secondaryLabel
            ] : [.strikethroughStyle: ""]
        )
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.attributedText = attributedText
        contentConfiguration.textProperties.numberOfLines = 3
        cell.contentConfiguration = contentConfiguration
        
        if let category = row.category {
            cell.accessories = [.customView(
                configuration: UICellAccessory.CustomViewConfiguration(
                    customView: CategoryAccessoryView(color: UIColor(Color(hex: category.color))),
                    placement: .trailing(displayed: .always, at: { _ in 0 }),
                    isHidden: category.color == "00000000"
                )
            )]
        } else {
            cell.accessories = []
        }
    }
    
    private func headerRegistrationHandler(
        supplementaryView: UICollectionViewListCell,
        elementKind: String,
        indexPath: IndexPath
    ) {
        let section = dataSource.sectionIdentifier(for: indexPath.section) ?? .other
        
        let text: String? =
        switch section {
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
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader,
            handler: headerRegistrationHandler
        )
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }
        
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        return dataSource
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.backgroundColor = UIColor(AppColors.backPrimary)
        
        configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return UISwipeActionsConfiguration() }
            
            return self.swipeAction(for: indexPath, isCompleted: true)
        }
        
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return UISwipeActionsConfiguration() }
                        
            return self.swipeAction(for: indexPath, isCompleted: false)
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
}
