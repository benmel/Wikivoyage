//
//  FavoritesTableViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import MagicalRecord

class FavoritesTableViewController: UITableViewController {

    var favoritePages = [SavedPage]()
    var selectedPage: SavedPage!
    
    private let tableRowHeight: CGFloat = 60
    private let cellIdentifier = "FavoritePage"
    private let segueIdentifier = "ShowWeb"
    
    private let placeholder = UIImage(named: Images.placeholder)!
    private let emptyBackgroundColor = UIColor.groupTableViewBackgroundColor()
    private let backgroundColor = UIColor.whiteColor()
    
    private let topMessage = "Favorite Locations"
    private let bottomMessage = "You don't have any favorite locations yet. Click the star button on a location to add it."
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyMessage()
        setupTable()
        
        clearsSelectionOnViewWillAppear = false
        navigationItem.rightBarButtonItem = editButtonItem()
        favoritePages = SavedPage.MR_findByAttribute("favorite", withValue: true, andOrderBy: "title", ascending: true) as! [SavedPage]
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
        let emptyBackgroundView = EmptyBackgroundView(image: Images.starLargeImage!, top: topMessage, bottom: bottomMessage)
        emptyBackgroundView.setNeedsUpdateConstraints()
        emptyBackgroundView.updateConstraintsIfNeeded()
        tableView.backgroundView = emptyBackgroundView
    }

    // MARK: - Table View Data Source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoritePages.count == 0 {
            tableView.backgroundColor = emptyBackgroundColor
            tableView.backgroundView?.hidden = false
        } else {
            tableView.backgroundColor = backgroundColor
            tableView.backgroundView?.hidden = true
        }
        
        return favoritePages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTableViewCell
        let favoritePage = favoritePages[indexPath.row]
        
        cell.title.text = favoritePage.title
        
        // If there's a thumbnail URL set URL, otherwise it's nil
        let url = (favoritePage.thumbnailURL != nil) ? NSURL(string: favoritePage.thumbnailURL!) : nil
        cell.thumbnail.sd_setImageWithURL(url, placeholderImage: placeholder)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let favoritePage = favoritePages[indexPath.row]
            if favoritePage.offline == true {
                // If the page is also offline, only update favorite property
                favoritePage.favorite = false
                favoritePages.removeAtIndex(indexPath.row)
            } else {
                favoritePages.removeAtIndex(indexPath.row).MR_deleteEntity()
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let favoritePage = favoritePages[indexPath.row]
        selectedPage = favoritePage
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let locationWebViewController = segue.destinationViewController as! LocationWebViewController
            configureLocationWebViewController(locationWebViewController)
        }
    }
    
    func configureLocationWebViewController(locationWebViewController: LocationWebViewController) {
        locationWebViewController.pageId = Int(selectedPage.id)
        locationWebViewController.pageTitle = selectedPage.title
        locationWebViewController.title = selectedPage.title
        locationWebViewController.delegate = self
        locationWebViewController.initialFavorite = selectedPage.favorite.boolValue
        locationWebViewController.initialOffline = selectedPage.offline.boolValue
    }
}

// MARK: - Location Web View Controller Delegate

extension FavoritesTableViewController: LocationWebViewControllerDelegate {
    func locationWebViewControllerDidUpdatePages(controller: LocationWebViewController) {
        favoritePages = SavedPage.MR_findByAttribute("favorite", withValue: true, andOrderBy: "title", ascending: true) as! [SavedPage]
        tableView.reloadData()
    }
}
