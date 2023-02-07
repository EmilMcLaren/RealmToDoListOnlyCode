//
//  AlertController.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import Foundation
import UIKit

class AlertController: UIAlertController {
    
    var doneButton = "Save"

    func actionForTaskList(with taskList: TaskList?, completition: @escaping (String) -> Void) {
        
        if taskList != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else {return}
            guard !newValue.isEmpty else {return}
            completition(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List name"
            textField.text = taskList?.name
        }
    }
    

    func actionForTask(with task: Task?, completition: @escaping (String, String) -> Void) {
        
        if task != nil {
            doneButton = "Udate"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else {return}
            guard !newTask.isEmpty else {return}
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completition(newTask, note)
            } else {
                completition(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = task?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = task?.note
        }
    }
}
