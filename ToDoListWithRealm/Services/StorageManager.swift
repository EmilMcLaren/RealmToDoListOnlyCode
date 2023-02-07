//
//  StorageManager.swift
//  ToDoListWithRealm
//
//  Created by Emil on 01.11.2022.
//

import Foundation
import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    let realm = try? Realm()
    
    private init() {}
    
    
    //MARK: For TaskList
    //(TaskList): save
    func save(taskList: TaskList) {
        write {
            realm?.add(taskList)
        }
    }
    //TaskList: delete
    func delete(taskList: TaskList) {
        write {
            let tasks = taskList.tasks
            realm?.delete(tasks)
            realm?.delete(taskList)
        }
    }
    //TaskList: edit
    func edit(taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    //TaskList: done
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    
    //MARK: For Tasks
    //Tasks: save
    func save(task: Task, taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    //Tasks: delete
    func delete(task: Task) {
        write {
            realm?.delete(task)
        }
    }
    //Tasks: edit
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    //Tasks: done
    func done(task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    
    //universal func for use
    private func write(_ completion: () -> Void) {
        do {
            try? realm?.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
}



//for get array from objects, not use in this project
extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }
