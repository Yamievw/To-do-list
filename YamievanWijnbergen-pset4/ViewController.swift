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
    //@IBOutlet weak var checkBoxx: UIButton!
    
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
    
    // add todos to todolist array and search for todos
    func addToList() {
        do {
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
            try database!.run(insert)
            addToList()
        } catch {
            // Error handling.
            print("Cannot add item to list: \(error)")
        }
        tableView.reloadData()
        inputItemField.text = ""
    }
    
    
    //    // Function to check off todos: when hidden not done, else done
    //    @IBAction func checkBox(_ sender: Any) {
    //        if checkBoxx.isHidden == false {
    //            checkBoxx.isHidden = true
    //        }
    //        else if checkBoxx.isHidden == true {
    //            checkBoxx.isHidden = false
    //        }
    //    }
    //
    
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
}





