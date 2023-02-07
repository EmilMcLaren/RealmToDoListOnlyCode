//
//   TasksViewController.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import UIKit
import Foundation
import RealmSwift

class TasksViewController: UITableViewController {

    
    let cellTask = "cellTask"
    var taskList: TaskList?
    
    //for filter data on "isComplete"
    var currentTask: Results<Task>?
    var completedTask: Results<Task>?
    
    //right item
    private func rightBarItem() {
        let buttom = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(ButtomPressed))
        
        navigationItem.rightBarButtonItems = [buttom, editButtonItem]
    }
    
    
    //MARK: VIEWDIDLOAD ============================================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        rightBarItem()
        
        title = taskList?.name
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellTask)
        
        currentTask = taskList?.tasks.filter("isComplete = false")
        completedTask = taskList?.tasks.filter("isComplete = true")
    }
    
    
    //MARK: Actions

    //action for right item
    @objc private func ButtomPressed() {
        showAlert()
    }
}
    

//MARK: TableViewDelegate
extension TasksViewController {
    
    //set section count
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    //set data to sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let completed = completedTask?.count else {return 0}
        guard let current = currentTask?.count else {return 0}
        
        return section == 0 ? current : completed
    }
    
    //heightForRow
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    //section header title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Currented Tasks" : "Completed Task"
    }
    
    //left swipe actions, DONE
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTask?[indexPath.row] : completedTask?[indexPath.row]
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        //done
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { (_,_, isDone) in
            StorageManager.shared.done(task: task!)
            
            let indexPathCurrentTask = IndexPath(row: (self.currentTask?.count ?? 0) - 1, section: 0)
            let indexPathCompletedTask = IndexPath(row: (self.completedTask?.count ?? 0) - 1, section: 1)
            
            let destinationIndexRow = indexPath.section == 0 ? indexPathCompletedTask : indexPathCurrentTask
            
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            isDone(true)
        }
        //backgroundColor of actions
        doneAction.backgroundColor = UIColor(red: 0.00, green: 0.78, blue: 0.39, alpha: 1.00)
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    //action for right swipe, DELETE, EDIT
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTask?[indexPath.row] : completedTask?[indexPath.row]
        
        //delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_,_,_) in
            StorageManager.shared.delete(task: task!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        //edit
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_,_, isDone)
            in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        //backgroundColor of actions
        editAction.backgroundColor = UIColor(red: 0.00, green: 0.35, blue: 0.98, alpha: 1.00)
        deleteAction.backgroundColor = UIColor(red: 0.94, green: 0.08, blue: 0.00, alpha: 1.00)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    //cell configurations
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTask, for: indexPath)
        let task = indexPath.section == 0 ? currentTask?[indexPath.row] : completedTask?[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task?.name
        content.secondaryText = task?.note
        cell.contentConfiguration = content
         
        return cell
    }

    //decelect rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: AlertController
extension TasksViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        
        let title = task != nil ? "Edit task" : "New task"
        
        
        let alert = AlertController(title: title, message: "What do yo want do?", preferredStyle: .alert)
        //for taskList unwrap
        guard let taskListGuard = self.taskList else {return}
        //guard let qqq = task! else {return}
        
        alert.actionForTask(with: task) { newValue, note in
            if let tast = task, let completion = completion {
                StorageManager.shared.edit(task: task!, name: newValue, note: note)
                completion()
            } else {
                let task = Task(value: [newValue, note])
                StorageManager.shared.save(task: task, taskList: taskListGuard)
                let rowIndex = IndexPath(row: (self.currentTask?.count ?? 0) - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        present(alert, animated: true)
    }
}

