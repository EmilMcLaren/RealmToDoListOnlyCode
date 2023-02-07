//
//  Extension + TableViewCell.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import Foundation
import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTask = taskList.tasks.filter("isComplete = false")
        let completedTask = taskList.tasks.filter("isComplete = true")
        
        var content = defaultContentConfiguration()
       
        content.text = taskList.name
       
        if !currentTask.isEmpty {
            content.secondaryText = "\(currentTask.count)"
            accessoryType = .none
        } else if currentTask.isEmpty {
            accessoryType = .checkmark
        } else {
            content.secondaryText = "0"
            accessoryType = .none
        }
        contentConfiguration = content
    }
}
