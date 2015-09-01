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

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    var locationSearchBar: UISearchBar!
    var resultsTable: UITableView!
    var searchResults: [SearchResult] = []
    
    let searchY: CGFloat = 64
    let searchYStart: CGFloat = 300
    let searchHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupSearchBar()
        setupTable()
    }
    
    func setupSearchBar() {
        locationSearchBar = UISearchBar()
        locationSearchBar.delegate = self
        locationSearchBar.frame = CGRect(x: 0, y: searchYStart, width: self.view.frame.width, height: searchHeight)
        self.view.addSubview(locationSearchBar)
    }
    
    func setupTable() {
        resultsTable = UITableView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.frame = CGRect(x: 0, y: searchYStart + searchHeight, width: self.view.frame.width, height: self.view.frame.height - searchY - searchHeight)
        resultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
    }
    
    // Search bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        showSearchBar(searchBar)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
        queryTitles(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.text = ""
        dismissSearchBar(searchBar)
        searchResults.removeAll()
        resultsTable.reloadData()
    }
    
    func showSearchBar(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.5, animations: {
            searchBar.frame.origin.y = self.searchY
            searchBar.showsCancelButton = true
            self.view.addSubview(self.resultsTable)
            self.resultsTable.frame.origin.y = self.searchY + self.searchHeight
        })
    }
    
    func dismissSearchBar(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.5, animations: {
            searchBar.frame.origin.y = self.searchYStart
            searchBar.showsCancelButton = false
            self.resultsTable.frame.origin.y = self.searchYStart + self.searchHeight
            self.resultsTable.removeFromSuperview()
        })
    }
    
    // Table view data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as! UITableViewCell
        cell.textLabel?.text = searchResults[indexPath.row].pageTitle
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchResult = searchResults[indexPath.row]
        let result = searchResults[indexPath.row]
        performSegueWithIdentifier("ShowLocation", sender: searchResult)
        resultsTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    // Helper functions
    func dismissKeyboard() {
        self.view.endEditing(true)
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
        searchResults.removeAll()
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: ["action": "query", "list": "prefixsearch", "pssearch": searchTerm, "pslimit": "100", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let results = json["query", "prefixsearch"]
                
                for (index: String, subJson: JSON) in results {
                    let title = subJson["title"].string
                    let pageid = subJson["pageid"].int
                    let searchResult = SearchResult(pageId: pageid!, pageTitle: title!)
                    self.searchResults.append(searchResult)
                }
            }
            
            self.resultsTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocation" {
            let destination = segue.destinationViewController as! LocationViewController
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

