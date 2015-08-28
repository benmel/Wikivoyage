//
//  MainViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var resultsTable: UITableView!
    
    let searchY: CGFloat = 64
    let searchYStart: CGFloat = 300
    let searchHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        searchBar.frame = CGRect(x: 0, y: searchYStart, width: self.view.frame.width, height: searchHeight)
        self.view.addSubview(searchBar)
        
        resultsTable = UITableView()
        resultsTable.frame = CGRect(x: 0, y: searchYStart + searchHeight, width: self.view.frame.width, height: self.view.frame.height - searchY - searchHeight)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.5, animations: {
            searchBar.frame.origin.y = self.searchY
            searchBar.showsCancelButton = true
            self.view.addSubview(self.resultsTable)
            self.resultsTable.frame.origin.y = self.searchY + self.searchHeight
        })
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.5, animations: {
            searchBar.frame.origin.y = self.searchYStart
            searchBar.showsCancelButton = false
            self.resultsTable.frame.origin.y = self.searchYStart + self.searchHeight
            self.resultsTable.removeFromSuperview()
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

