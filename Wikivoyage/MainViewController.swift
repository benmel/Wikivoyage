//
//  MainViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PureLayout
import SDWebImage

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    var topView: UIView!
    var bottomView: UIView!
    
    var locationSearchBar: UISearchBar!
    var searchBarDimensionConstraint: NSLayoutConstraint?
    var searchBarEdgeConstraint: NSLayoutConstraint?
    var searchBarTop: Bool = false
    
    var searchButton: UIButton!
    var searchButtonWidth: NSLayoutConstraint?
    var searchButtonHeight: NSLayoutConstraint?
    var searchButtonEdgeConstraint: NSLayoutConstraint?
    
    var favoriteButton: UIButton!
    var offlineButton: UIButton!
    
    var resultsTable: UITableView!
    var searchResults: [SearchResult] = []
    
    var didSetupContraints: Bool = false
    
    var lastRequestid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSearchBar()
        setupSearchButton()
        setupButtons()
        setupTable()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetSearchBar(locationSearchBar, animated: false)
    }
    
    override func updateViewConstraints() {
        
        if !didSetupContraints {

            // Align top and bottom views
            topView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            bottomView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            let views: NSArray = [topView, bottomView]
            views.autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: 0)
            
            // Align search bar at top
            locationSearchBar.autoAlignAxisToSuperviewAxis(.Vertical)
            locationSearchBar.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            locationSearchBar.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            
            // Align search button
            searchButton.autoAlignAxisToSuperviewAxis(.Vertical)
            
            // Align results table
            resultsTable.autoAlignAxisToSuperviewAxis(.Vertical)
            resultsTable.autoPinEdgeToSuperviewEdge(.Left, withInset: 0)
            resultsTable.autoPinEdgeToSuperviewEdge(.Right, withInset: 0)
            resultsTable.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: locationSearchBar)
            
            // Align buttons
            favoriteButton.autoSetDimension(.Width, toSize: 250)
            favoriteButton.autoAlignAxisToSuperviewAxis(.Vertical)
            offlineButton.autoSetDimension(.Width, toSize: 250)
            offlineButton.autoAlignAxisToSuperviewAxis(.Vertical)
            let buttons: NSArray = [favoriteButton, offlineButton]
            buttons.autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: 30)
            
            didSetupContraints = true
        }
        
        searchButtonWidth?.autoRemove()
        searchButtonHeight?.autoRemove()
        searchButtonEdgeConstraint?.autoRemove()
        
        if searchBarTop {
            searchButtonWidth = searchButton.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            searchButtonHeight = searchButton.autoSetDimension(.Height, toSize: 44)
            searchButtonEdgeConstraint = searchButton.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        } else {
            searchButtonWidth = searchButton.autoSetDimension(.Width, toSize: 300)
            searchButtonHeight = searchButton.autoSetDimension(.Height, toSize: 60)
            searchButtonEdgeConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Bottom)
        }
        
        super.updateViewConstraints()
    }
    
    func setupViews() {
        topView = UIView.newAutoLayoutView()
        bottomView = UIView.newAutoLayoutView()
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
    }

    func setupSearchBar() {
        locationSearchBar = UISearchBar.newAutoLayoutView()
        locationSearchBar.delegate = self
        locationSearchBar.showsCancelButton = true
        locationSearchBar.alpha = 0
        topView.addSubview(locationSearchBar)
    }
    
    func setupSearchButton() {
        searchButton = UIButton.buttonWithType(.Custom) as! UIButton
        searchButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchButton.setTitle("Search", forState: .Normal)
        searchButton.addTarget(self, action: "searchClicked:", forControlEvents: .TouchUpInside)
        
        searchButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        searchButton.backgroundColor = .redColor()
        searchButton.layer.cornerRadius = 5
        
        topView.addSubview(searchButton)
    }
    
    func setupButtons() {
        favoriteButton = UIButton.buttonWithType(.System) as! UIButton
        favoriteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        favoriteButton.setTitle("Favorite Locations", forState: .Normal)
        favoriteButton.addTarget(self, action: "favoriteClicked:", forControlEvents: .TouchUpInside)
        
        favoriteButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        favoriteButton.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        favoriteButton.layer.cornerRadius = 5
        
        bottomView.addSubview(favoriteButton)
        
        offlineButton = UIButton.buttonWithType(.System) as! UIButton
        offlineButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        offlineButton.setTitle("Offline Locations", forState: .Normal)
        offlineButton.addTarget(self, action: "offlineClicked:", forControlEvents: .TouchUpInside)
        
        offlineButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        offlineButton.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        offlineButton.layer.cornerRadius = 5
        
        bottomView.addSubview(offlineButton)
    }
    
    func setupTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.alpha = 0
        resultsTable.registerClass(SearchResultTableViewCell.self, forCellReuseIdentifier: "TableCell")
        resultsTable.rowHeight = 60
        resultsTable.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        resultsTable.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(resultsTable)
    }
    
    func searchClicked(sender: UIButton!) {
        showSearchBar(locationSearchBar)
    }

    func favoriteClicked(sender: UIButton!) {
        performSegueWithIdentifier("ShowFavorites", sender: sender)
    }
    
    func offlineClicked(sender: UIButton!) {
        performSegueWithIdentifier("ShowOffline", sender: sender)
    }
    
    // Search bar delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
        if !searchBar.text.isEmpty {
            queryTitles(searchBar.text)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resetSearchBar(searchBar, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let delay = 0.3
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue()) {
                if searchText == self.locationSearchBar.text {
                    self.queryTitles(searchText)
                }
            }
        }
    }
    
    // Search bar helper methods
    func resetSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBar.text = ""
        dismissSearchBar(searchBar, animated: animated)
        searchResults.removeAll()
        resultsTable.reloadData()
    }
    
    func showSearchBar(searchBar: UISearchBar) {
        searchBarTop = true
        
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.5,
            animations: {
                self.view.layoutIfNeeded()
            }, completion: { finished in
                UIView.animateWithDuration(0.2,
                    animations: {
                        searchBar.alpha = 1
                        self.resultsTable.alpha = 1
                        self.searchButton.alpha = 0
                    }, completion: { finished in
                        searchBar.becomeFirstResponder()
                    })
            })
    }
    
    func dismissSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBarTop = false
        searchBar.resignFirstResponder()
        
        if animated {
            UIView.animateWithDuration(0.2,
                animations: {
                    searchBar.alpha = 0
                    self.resultsTable.alpha = 0
                    self.searchButton.alpha = 1
                }, completion:  { finished in
                    self.view.setNeedsUpdateConstraints()
                    self.view.updateConstraintsIfNeeded()
                    UIView.animateWithDuration(0.5,
                        animations: {
                            self.view.layoutIfNeeded()
                        })
                })
        } else {
            self.view.setNeedsUpdateConstraints()
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
            searchBar.alpha = 0
            self.resultsTable.alpha = 0
            self.searchButton.alpha = 1
        }
    }
    
    // Table view data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! SearchResultTableViewCell
        
        cell.title.text = searchResults[indexPath.row].pageTitle

        let placeholder = UIImage(named: "placeholder")
        if let thumbnailURL = searchResults[indexPath.row].thumbnailURL, url = NSURL(string: thumbnailURL) {
            cell.thumbnail.sd_setImageWithURL(url, placeholderImage: placeholder!)
        } else {
            cell.thumbnail.sd_setImageWithURL(nil, placeholderImage: placeholder!)
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.isEmpty {
            tableView.separatorStyle = .None
        } else {
            tableView.separatorStyle = .SingleLine
        }
        
        return searchResults.count
    }
    
    // Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchResult = searchResults[indexPath.row]
        let result = searchResults[indexPath.row]
        performSegueWithIdentifier("ShowWeb", sender: searchResult)
        resultsTable.deselectRowAtIndexPath(indexPath, animated: true)
        dismissKeyboard()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    // Helper functions
    func dismissKeyboard() {
        locationSearchBar.resignFirstResponder()
        enableCancelButton(locationSearchBar)
    }
    
    func enableCancelButton(searchBar: UISearchBar) {
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKindOfClass(UIButton) {
                    let button = subview as! UIButton
                    button.enabled = true
                }
            }
        }
    }
    
    func queryTitles(searchTerm: String) {
        // Update lastRequestid
        lastRequestid = searchTerm
        let limit = 20
        let size = 128
        
        let parameters: [String: AnyObject] = [
            "action": "query",
            "format": "json",
            "requestid": searchTerm,
            "generator": "prefixsearch",
            "gpssearch": searchTerm,
            "gpslimit": limit,
            "prop": "pageimages",
            "piprop": "thumbnail",
            "pithumbsize": size,
            "pilimit": limit
        ]
        
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: parameters).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let requestid = json["requestid"].stringValue
                // Only update results using latest request
                if requestid == self.lastRequestid {
                    self.searchResults.removeAll(keepCapacity: false)
                    let results = json["query", "pages"]
                    
                    for (index: String, subJson: JSON) in results {
                        let index = subJson["index"].int
                        let pageid = subJson["pageid"].int
                        let title = subJson["title"].string
                        let thumbnail = subJson["thumbnail"]["source"].string
                        
                        let searchResult = SearchResult(index: index!, pageId: pageid!, pageTitle: title!, thumbnailURL: thumbnail)
                        self.searchResults.append(searchResult)
                        self.searchResults.sort { $0.index < $1.index }
                    }
                    
                    self.resultsTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWeb" {
            let destination = segue.destinationViewController as! LocationWebViewController
            let searchResult = sender as! SearchResult
            destination.pageId = searchResult.pageId
            destination.pageTitle = searchResult.pageTitle
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

