//
//  OfflineTableViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import MagicalRecord

class OfflineTableViewController: UITableViewController {

    var offlinePages = [SavedPage]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        offlinePages = SavedPage.MR_findByAttribute("offline", withValue: true, andOrderBy: "title", ascending: true) as! [SavedPage]
    }

    // MARK: - Table View Data Source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offlinePages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OfflinePage", forIndexPath: indexPath) as! UITableViewCell
        let offlinePage = offlinePages[indexPath.row]
        cell.textLabel?.text = offlinePage.title
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let offlinePage = offlinePages[indexPath.row]
            if offlinePage.favorite == true {
                // If the page is also a favorite, only update offline property
                offlinePage.offline = false
                offlinePages.removeAtIndex(indexPath.row)
            } else {
                offlinePages.removeAtIndex(indexPath.row).MR_deleteEntity()
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let offlinePage = offlinePages[indexPath.row]
        performSegueWithIdentifier("ShowWeb", sender: offlinePage)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWeb" {
            let vc = segue.destinationViewController as! OfflineWebViewController
            let offlinePage = sender as! SavedPage
            vc.html = offlinePage.html
            vc.title = offlinePage.title
        }
    }
}
