//
//  ViewController.swift
//  YamievanWijnbergen-pset4
//
//  Created by Yamie van Wijnbergen on 05/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var inputItemField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var checkBox: UIButton!
    
    var todoitems = [String]()
    
    // SQLite database
    private var database: Connection?
    
    let todolist = Table("todolist")
    let todos = Expression<String>("todos")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
        addToList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set up database.
    private func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch {
            // Error handling.
            print("Cannot connect to database: \(error)")
        }
    }
    
    // Create table.
    private func createTable(){
        do {
            try database!.run(todolist.create(ifNotExists: true) { t in
                t.column(todos)
            } )
        } catch {
            print("Cannot create table: \(error)")
        }
    }

    // add todos to todolist array
    func addToList() {
        do {
            todoitems.removeAll()
            for todo in try database!.prepare(todolist) {
                if todo[todos].isEmpty != true {
                    todoitems.append(todo[todos])
                }
            }
        } catch {
            print("Unable to append item: \(error)")
        }
    }

    // Insert new todo into todolist-database.
    @IBAction func addItemButton(_ sender: Any) {
        let insert = todolist.insert(todos <- inputItemField.text!)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
            print(todoitems)
            addToList()
        } catch {
            // Error handling.
            print("Cannot add item to list: \(error)")
        }
        tableView.reloadData()
        inputItemField.text = ""
    }


        // Function to check off todos: when hidden not done, else done
        @IBAction func checkBox(_ sender: UIButton) {
            if sender.backgroundColor == .lightGray {
                sender.backgroundColor = .white
            }
            else if sender.backgroundColor == .white {
                sender.backgroundColor = .lightGray
            }
            else {
                sender.backgroundColor = .white
            }
        }
    

    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoitems.count
    }
    
    // create new cell
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as! ToDoCell
        
        cell.itemLabel.text = todoitems[indexPath.row]
        
        return cell
    }
    
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let delete = todolist.filter(todos == todoitems[indexPath.row])
            do {
                try database!.run(delete.delete())
                todoitems.remove(at: indexPath[1])
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Unable to delete row: \(error)")
            }
            print(todoitems)
        }
    }
}







