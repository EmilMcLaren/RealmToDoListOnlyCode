//
//  ViewController.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let cellID = "cell"
    var tasksList: Results<TaskList>?
    var tasksListFilter: Results<TaskList>?
    
    
    //MARK: UI ELEMENTS
    
    
    //MARK: Refresh
    
    let addRefreshControl = UIRefreshControl()
    
    //refrash
    private func refresh() {
        addRefreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        self.tableView.refreshControl = addRefreshControl
    }
    
  
    
    //MARK: SearchController Configurate

    //Right and left items
    private func rightAndLeftItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openTasks))
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    
    //SegmentedController
    private lazy var segmentCont: UISegmentedControl = {
        let segmentTitles = ["Date", "A-Z"]
        let segment = UISegmentedControl(items: segmentTitles)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(chooseSegmentIndex), for: .valueChanged)
        
        return segment
    }()
    
    
    
    //View with SegmentController
    private var viewWithSegmentController: UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        view.backgroundColor = .white
        view.addSubview(segmentCont)
        //set Constraint for view
        segmentCont.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentCont.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            segmentCont.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.center.x),
            
            segmentCont.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentCont.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        return view
    }
    
    
    //Set NavigationBar and SearchController
    private func navBarAndSearchCont() {
        title = "Task Lists"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBar = UINavigationBarAppearance()
        navBar.configureWithOpaqueBackground()
        navBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navBar.backgroundColor = #colorLiteral(red: 0.8496792912, green: 0.9519454837, blue: 1, alpha: 1)
        
        navigationController?.navigationBar.scrollEdgeAppearance = navBar
        navigationController?.navigationBar.standardAppearance = navBar
        
        self.navigationController?.hidesBarsOnTap = false
        setSearchController()
    }

    
    
    
    //MARK: VIEWDIDLOAD ============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navBarAndSearchCont()
        rightAndLeftItems()
        //add tableView header
        self.tableView.tableHeaderView = viewWithSegmentController
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        //get objects from data
        tasksList = StorageManager.shared.realm?.objects(TaskList.self)
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    
    
    //MARK: Actions
    
    //for refresh
    @objc private func refreshAction(refreshControl: UIRefreshControl) {
        tasksList = segmentCont.selectedSegmentIndex == 0 ?
        tasksList?.sorted(byKeyPath: "date", ascending: true)
        : tasksList?.sorted(byKeyPath: "name", ascending: true)
        
        self.tableView.reloadData()
        self.addRefreshControl.endRefreshing()
    }
    
    //for rightBarButtonItem
    @objc private func openTasks() {
        showAlert()
    }
    
    //chooseSegmentIndex
    @objc func chooseSegmentIndex(_ segmetControl: UISegmentedControl) {
        tasksList = segmentCont.selectedSegmentIndex == 0 ?
        tasksList?.sorted(byKeyPath: "date", ascending: true)
        : tasksList?.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    //MARK: SearchController Configurate
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty || searchBarScopeIsFiltering)
    }
    
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["All"]
        searchController.searchBar.showsScopeBar = false
        searchController.searchBar.delegate = self
    }


    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex]
        guard let text = searchController.searchBar.text else { return }
        guard let scope2 = scope else {return}
        filterContentForSearchText(text, scope: scope2)
    }

    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if scope == "All" {
            tasksListFilter = tasksList?.filter("name CONTAINS[c] '\(searchText)'").sorted(byKeyPath: "name", ascending: true)
        }
        tableView.reloadData()
    }
}



//MARK: TableViewDelegate
extension TaskListViewController {
    
    //get data objects to rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return tasksListFilter?.count ?? 0
        } else {
            return tasksList?.count ?? 0
        }
    }
    
    //configuration cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        var taski: TaskList?
        
        if isFiltering {
            taski = tasksListFilter?[indexPath.row]
        } else {
            taski = tasksList?[indexPath.row]
        }
        
        guard let taski2 = taski else {
            return cell
        }
        
        cell.configure(with: taski2)
        return cell
    }
    
    //height row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    //action for left swipe, DONE
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let tasks = tasksList![indexPath.row]
        
        //done
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_,_, isDone) in
            StorageManager.shared.done(taskList: tasks)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        //backgroundColor of actions
        doneAction.backgroundColor = UIColor(red: 0.00, green: 0.78, blue: 0.39, alpha: 1.00)
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    //action for right swipe, DELETE, EDIT
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let tasks = tasksList![indexPath.row]
        
        //delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_,_,_) in
            StorageManager.shared.delete(taskList: tasks)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        //edit
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_,_, isDone)
            in
            self.showAlert(tasklist: tasks) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        //backgroundColor of actions
        editAction.backgroundColor = UIColor(red: 0.00, green: 0.35, blue: 0.98, alpha: 1.00)
        deleteAction.backgroundColor = UIColor(red: 0.94, green: 0.08, blue: 0.00, alpha: 1.00)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    //work, when select a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let indexPathTL = tableView.indexPathForSelectedRow else {return}
        //for pass to TasksViewController from cell
        let vc = TasksViewController()
        vc.taskList = tasksList?[indexPathTL.row]
        //navigate
        navigationController?.pushViewController(vc, animated: true)
        //decelect animate
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



//MARK: AlertController
extension TaskListViewController {
    private func showAlert(tasklist: TaskList? = nil, completion: (() -> Void)? = nil) {
        
        let title = tasklist != nil ? "Edit list" : "New list"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.actionForTaskList(with: tasklist) { newValue in
            if let tasklist = tasklist, let completion = completion {
                StorageManager.shared.edit(taskList: tasklist, newValue: newValue)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: (self.tasksList?.count ?? 0) - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        present(alert, animated: true)
    }
}
