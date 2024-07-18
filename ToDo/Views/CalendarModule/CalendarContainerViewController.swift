import UIKit
import SwiftUI

class CalendarContainerViewController: UIViewController {
    
    var toDoItemsStore: ToDoItemsStore
    var toDoItems: [ToDoItem]
    
    private var datesView: UIView!
    private var listView: UIView!
    
    private lazy var datesViewController: CalendarDatesViewController = {
        let viewModel = CalendarDatesViewController.ViewModel(toDoItems: toDoItems)
        let datesViewController = CalendarDatesViewController(viewModel: viewModel)
        datesViewController.delegate = self
        
        return datesViewController
    }()
    
    private lazy var listViewController: CalendarListViewController = {
        let viewModel = CalendarListViewController.ViewModel(toDoItems: toDoItems)
        let listViewController = CalendarListViewController(viewModel: viewModel)
        listViewController.delegate = self
        
        return listViewController
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var newButton: UIButton = {
        let fontConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .title3))
        let weightConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        
        let image = UIImage(systemName: "plus")?
            .applyingSymbolConfiguration(fontConfiguration)?
            .applyingSymbolConfiguration(weightConfiguration)
        
        let button = UIButton(configuration: .filled())
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.4
        
        return button
    }()
    
    init(toDoItemsStore: ToDoItemsStore) {
        self.toDoItemsStore = toDoItemsStore
        self.toDoItems = toDoItemsStore.currentToDoItems
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
        
        let action = UIAction { [weak self] _ in
            self?.showDetailView(forItemAt: nil)
        }
        
        newButton.addAction(action, for: .touchUpInside)
    }
    
    private func updateData() {
        toDoItems = toDoItemsStore.currentToDoItems
        
        listViewController.viewModel = .init(toDoItems: toDoItems)
        listViewController.updateSnapshot()
        
        datesViewController.viewModel = .init(toDoItems: toDoItems)
        datesViewController.updateSnapshot()
    }
    
    private func layoutViews() {
        // ViewControllers.
        datesView = datesViewController.view
        listView = listViewController.view
        
        let stackView = UIStackView(arrangedSubviews: [datesView, separatorView, listView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            datesView.heightAnchor.constraint(equalToConstant: 80),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Button.
        view.addSubview(newButton)
        
        NSLayoutConstraint.activate([
            newButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            newButton.heightAnchor.constraint(equalToConstant: 44),
            newButton.heightAnchor.constraint(equalTo: newButton.widthAnchor)
        ])
    }
    
    @objc
    private func showDetailView(forItemAt indexPath: IndexPath?) {
        let toDoItem: ToDoItem?
        if let indexPath = indexPath {
            toDoItem = listViewController.dataSource.itemIdentifier(for: indexPath)
        } else {
            toDoItem = nil
        }
        
        let viewController = UIHostingController(
            rootView: ToDoItemDetail(
                editingToDoItem: .constant(toDoItem),
                onSave: onSave,
                onDismiss: onDismiss,
                onDelete: onDelete
            )
            .modelContainer(for: Category.self)
        )
        
        present(viewController, animated: true)
    }
    
    private func onSave(_ toDoItem: ToDoItem) {
        toDoItemsStore.addOrUpdate(toDoItem)
        updateData()
        
        listViewController.scrollToDate(toDoItem.dueDate)
        datesViewController.selectDate(toDoItem.dueDate)
        
        onDismiss()
    }
    
    private func onDismiss() {
        dismiss(animated: true)
    }
    
    private func onDelete(_ toDoItem: ToDoItem) {
        toDoItemsStore.delete(toDoItem)
        updateData()
        
        onDismiss()
    }
}

extension CalendarContainerViewController: CalendarContainerViewControllerDelegate {
    func didSelectDate(_ viewController: CalendarDatesViewController, date: Date?) {
        listViewController.scrollToDate(date)
    }
    
    func didSelectToDoItem(_ viewController: CalendarListViewController, at indexPath: IndexPath) {
        showDetailView(forItemAt: indexPath)
    }
    
    func didScrollThroughDateSection(_ viewController: CalendarListViewController, date: Date?) {
        datesViewController.selectDate(date)
    }
    
    func didCompleteToDoItem(_ viewController: CalendarListViewController, toDoItem: ToDoItem, isCompleted: Bool) {
        let updatedToDoItem = ToDoItem(
            id: toDoItem.id,
            text: toDoItem.text,
            importance: toDoItem.importance,
            dueDate: toDoItem.dueDate,
            category: toDoItem.category,
            categoryId: toDoItem.categoryId,
            isCompleted: isCompleted,
            dateCreated: toDoItem.dateCreated,
            dateEdited: toDoItem.dateEdited
        )
        
        toDoItemsStore.addOrUpdate(updatedToDoItem)
        
        updateData()
    }
}
