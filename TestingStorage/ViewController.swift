//
//  ViewController.swift
//  TestingStorage
//
//  Created by Mohammad AlMarzouq on 4/28/15.
//  Copyright (c) 2015 KBSoft. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var names = [NSManagedObject]()
    
    @IBAction func addName(sender: AnyObject) {
        
        var alert = UIAlertController(title: "New name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let textField = alert.textFields![0] as! UITextField
                
                self.saveName(textField.text)
                
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    func saveName(name: String){
        //1 These 2 steps are needed whenever you want to save
        // or you want to fetch from DB
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //You ask CoreData to give you the description of the table
        //CoreData needs to know how the entety looks like and what
        //attributes it has and what relationships exists before it can
        //store anything to the tables. Otherwise it will not know how
        //to store the data in the table
        //So these 2 steps are important before storing into a tables
        //Just replace Person with the name of the entety you want to store to
        let entity =  NSEntityDescription.entityForName("Person",
            inManagedObjectContext:
            managedContext)
        
        //now create an object that looks like the SQL table to
        //we can put our data in it (this object will hold our data)
        let person = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        
        //Now start putting information into the new object
        //Our table was simple with a single attribute,
        //you can add all the attributes you want here
        person.setValue(name, forKey: "name")
        
        //This is the step to save into the database
        // it also includes an error handling step in case
        //something goes wrong, you will see an error message
        //in the log
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        //This is also important, because we also need to put the data in memory
        //so it can show on the table view.
        names.append(person)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //1 These 2 steps are needed whenever you want to save
        // or you want to fetch from DB
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 This is where you write your query
        // it is not SQL but it is similar
        // read about NSFetchRequest to understand how queries
        // are constructed
        let fetchRequest = NSFetchRequest(entityName:"Person")
        
        //3 This is the step that executes the query we create
        // this is where we talk to the database
        // the data will be brought in an placed in fetchedResults
        // errors will also be placed into fetchedResults if anything is wrong
        var error: NSError?
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        
        // Here we should if fetchedResults is data or error
        // if it is data, then it will be a list that we can
        // simple replace our table list (called names) to be the result
        // so the data is displayed on the table
        // if it was an error we display a log message error
        if let results = fetchedResults {
            names = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return names.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
                as! UITableViewCell
            
            let person = names[indexPath.row]
            cell.textLabel!.text = person.valueForKey("name") as? String
            
            return cell
    }
}

