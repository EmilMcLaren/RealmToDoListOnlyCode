//
//   Task.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import Foundation
import RealmSwift


class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}

class TaskList: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}
