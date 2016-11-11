//
//  WorkListTableViewController.swift
//  FirebaseDemo
//
//  Created by Quang Minh Trinh on 8/11/16.
//  Copyright © 2016 Quang Minh Trinh. All rights reserved.
//

import UIKit
import Firebase
class WorkListTableViewController: UITableViewController {
    // MARK: - Properties
    var works: [Work] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var databaseRef:FIRDatabaseReference!
    var remoteConfig: FIRRemoteConfig!
    let backgroundColorKey = "backgroundColor"
    let textColorKey = "textColor"
    var backgroundColor:UIColor! = UIColor(rgb: 0xFFFFFF)
    var textColor:UIColor = UIColor(rgb: 0x000000)
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRDatabase.database().persistenceEnabled = true
        databaseRef = FIRDatabase.database().reference().child("/works/\(appDelegate.user!.id)/worksCreated")
        
        databaseRef.keepSynced(true)
        self.remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("RemoteConfigDefaults")
//        databaseRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            if snapshot.value != nil {
//                for child in snapshot.children {
//                    if child is FIRDataSnapshot {
//                        let work = Work(snapshot: child as! FIRDataSnapshot)
//                        self.works.append(work)
//                    }
//                }
//                self.tableView.reloadData()
//            }
//            }, withCancelBlock: { error in
//                print(error.localizedDescription)
//        })
        databaseRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if snapshot.value != nil {
                let work = Work(snapshot: snapshot)
                self.works.append(work)
                self.tableView.reloadData()
            }
            }, withCancelBlock: { error in
                print(error.localizedDescription)
        })
        databaseRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
            if snapshot.value != nil {
                let work = Work(snapshot: snapshot)
                let index = self.works.indexOf({$0.id == work.id})
                if index != nil {
                    self.works.removeAtIndex(index!)
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            }
            }, withCancelBlock: { error in
                print(error.localizedDescription)
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        fetchConfig()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return works.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkCell", forIndexPath: indexPath) as! WorkCell

        // Configure the cell...
        cell.workName.text = works[indexPath.row].workName
        if remoteConfig[backgroundColorKey].numberValue != nil {
            cell.backgroundColor = UIColor(rgb: remoteConfig[backgroundColorKey].numberValue!.unsignedIntegerValue)
        }
        if remoteConfig[textColorKey].numberValue != nil {
            cell.workName.textColor = UIColor(rgb: remoteConfig[textColorKey].numberValue!.unsignedIntegerValue)
            cell.tintColor = UIColor(rgb: remoteConfig[textColorKey].numberValue!.unsignedIntegerValue)
//            cell.workName.tintColor = UIColor(rgb: remoteConfig[textColorKey].numberValue!.unsignedIntegerValue)
            
        }
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            databaseRef.child("/\(works[indexPath.row].id!)").removeValue()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addBtn_TouchUpInside(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { (action: UIAlertAction!) -> Void in
                                        
                                        let textField = alert.textFields![0] 
                                        let workItem = Work(workName: textField.text!, userId: self.appDelegate.user!.id, id: "")
                                        self.addNewWork(workItem)
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
    
    @IBAction func signOutBtn_TouchUpInside(sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            
        }
        
    }
    func addNewWork(work: Work) {
        let key = databaseRef.child("works/\(appDelegate.user!.id)/worksCreated").childByAutoId().key
        let workDict: [String:AnyObject] = ["name" : work.workName!, "creator": work.userId!, "id": key]
        
        let childUpdate = ["\(key)": workDict]
        self.databaseRef.updateChildValues(childUpdate)
        
    }
    
    func fetchConfig() {
        
        var expirationDuration = 3600
        // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
        // the server.
        if (remoteConfig.configSettings.isDeveloperModeEnabled) {
            expirationDuration = 0
        }
        
        // [START fetch_config_with_callback]
        // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
        // fetched and cached config would be considered expired because it would have been fetched
        // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
        // throttling is in progress. The default expiration duration is 43200 (12 hours).
        remoteConfig.fetchWithExpirationDuration(NSTimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == FIRRemoteConfigFetchStatus.Success) {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
                print(self.remoteConfig)
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
            self.changeAppearance()
        }
        // [END fetch_config_with_callback]
    }
    func changeAppearance() {
        tableView.backgroundColor = UIColor(rgb: (remoteConfig[backgroundColorKey].numberValue?.unsignedIntegerValue)!)
        self.tableView.reloadData()
    }
    
}
