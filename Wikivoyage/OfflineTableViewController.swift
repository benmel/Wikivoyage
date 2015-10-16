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
    var selectedPage: SavedPage!
    
    private let tableRowHeight: CGFloat = 60
    private let cellIdentifier = "OfflinePage"
    private let segueIdentifier = "ShowWeb"
    
    private let placeholder = UIImage(named: Images.placeholder)!
    private let emptyBackgroundColor = UIColor.groupTableViewBackgroundColor()
    private let backgroundColor = UIColor.whiteColor()
    
    private let errorMessage = "Offline page not available"
    private let topMessage = "Offline Locations"
    private let bottomMessage = "You don't have any offline locations yet. Click the download button on a location to save it for offline reading."
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyMessage()
        setupTable()
        
        clearsSelectionOnViewWillAppear = false
        navigationItem.rightBarButtonItem = editButtonItem()
        offlinePages = SavedPage.MR_findByAttribute("offline", withValue: true, andOrderBy: "title", ascending: true) as! [SavedPage]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Need this to clear on back swipe
        if let row = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(row, animated: animated)
        }
    }
    
    // MARK: - Initialization
    
    func setupTable() {
        tableView.rowHeight = tableRowHeight
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func setupEmptyMessage() {
        let emptyBackgroundView = EmptyBackgroundView(image: placeholder, top: topMessage, bottom: bottomMessage)
        emptyBackgroundView.setNeedsUpdateConstraints()
        emptyBackgroundView.updateConstraintsIfNeeded()
        tableView.backgroundView = emptyBackgroundView
    }

    // MARK: - Table View Data Source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if offlinePages.count == 0 {
            tableView.backgroundColor = emptyBackgroundColor
            tableView.backgroundView?.hidden = false
        } else {
            tableView.backgroundColor = backgroundColor
            tableView.backgroundView?.hidden = true
        }
        
        return offlinePages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTableViewCell
        let offlinePage = offlinePages[indexPath.row]
        
        cell.title.text = offlinePage.title
        
        // If there's a thumbnail URL set URL, otherwise it's nil
        let url = (offlinePage.thumbnailURL != nil) ? NSURL(string: offlinePage.thumbnailURL!) : nil
        cell.thumbnail.sd_setImageWithURL(url, placeholderImage: placeholder)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
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
        selectedPage = offlinePage
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let offlineWebViewController = segue.destinationViewController as! OfflineWebViewController
            configureOfflineWebViewController(offlineWebViewController)
        }
    }
    
    func configureOfflineWebViewController(offlineWebViewController: OfflineWebViewController) {
        offlineWebViewController.html = (selectedPage.html != nil) ? selectedPage.html : errorMessage
        offlineWebViewController.title = selectedPage.title
    }
}
