//
//  ViewController.swift
//  YamievanWijnbergen-pset4
//
//  Created by Yamie van Wijnbergen on 05/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    
    @IBOutlet weak var inputItemField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var todoitems = [String]()
    
    // SQLite database
    private var database: Connection?
    
    let todolist = Table("todolist")
    let todos = Expression<String>("todos")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Insert todos into "todolist".
    @IBAction func addItemButton(_ sender: Any) {
        let insert = todolist.insert(todos <- inputItemField.text!)
        
        do {
            try database!.run(insert)
        } catch {
            // Error handling.
            print("Cannot add item to list: \(error)")
        }
        self.tableView.reloadData()
        inputItemField.text = ""
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

