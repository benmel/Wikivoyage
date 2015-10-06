//
//  MainViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class MainViewController: UIViewController {

    var topView, bottomView: UIView!
    
    var locationSearchBar: UISearchBar!
    var searchBarDimensionConstraint, searchBarEdgeConstraint: NSLayoutConstraint?
    var searchBarTop = false
    
    var searchButton: UIButton!
    var searchButtonWidth, searchButtonHeight, searchButtonEdgeConstraint: NSLayoutConstraint?
    
    var favoriteButton, offlineButton: UIButton!
    
    var resultsTable: UITableView!
    var searchResults = [SearchResult]()
    var lastRequestid: String!
    
    var didSetupContraints = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSearchBar()
        setupSearchButton()
        setupOtherButtons()
        setupTable()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetSearchBar(locationSearchBar, animated: false)
    }
    
    // MARK: - Initialization
    
    func setupViews() {
        topView = UIView.newAutoLayoutView()
        bottomView = UIView.newAutoLayoutView()
        view.addSubview(topView)
        view.addSubview(bottomView)
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
    
    func setupOtherButtons() {
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
        resultsTable.registerClass(SearchResultTableViewCell.self, forCellReuseIdentifier: "TableCell")
        
        resultsTable.alpha = 0
        resultsTable.rowHeight = 60
        // Start separator line at 80px
        resultsTable.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        // Disable separator lines for empty cells
        resultsTable.tableFooterView = UIView(frame: CGRectZero)
        
        view.addSubview(resultsTable)
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupContraints {
            topView.autoMatchDimension(.Width, toDimension: .Width, ofView: view)
            bottomView.autoMatchDimension(.Width, toDimension: .Width, ofView: view)
            let views = NSArray(array: [topView, bottomView])
            views.autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: 0)
            
            locationSearchBar.autoAlignAxisToSuperviewAxis(.Vertical)
            locationSearchBar.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            locationSearchBar.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            
            searchButton.autoAlignAxisToSuperviewAxis(.Vertical)
            
            favoriteButton.autoSetDimension(.Width, toSize: 250)
            favoriteButton.autoAlignAxisToSuperviewAxis(.Vertical)
            offlineButton.autoSetDimension(.Width, toSize: 250)
            offlineButton.autoAlignAxisToSuperviewAxis(.Vertical)
            let buttons = NSArray(array: [favoriteButton, offlineButton])
            buttons.autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: 30)
            
            resultsTable.autoAlignAxisToSuperviewAxis(.Vertical)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            resultsTable.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: locationSearchBar)
            
            didSetupContraints = true
        }
        
        searchButtonWidth?.autoRemove()
        searchButtonHeight?.autoRemove()
        searchButtonEdgeConstraint?.autoRemove()
        
        if searchBarTop {
            searchButtonWidth = searchButton.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            searchButtonHeight = searchButton.autoSetDimension(.Height, toSize: 44)
            searchButtonEdgeConstraint = searchButton.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        } else {
            searchButtonWidth = searchButton.autoSetDimension(.Width, toSize: 300)
            searchButtonHeight = searchButton.autoSetDimension(.Height, toSize: 60)
            searchButtonEdgeConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Bottom)
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - User Interaction
    
    func searchClicked(sender: UIButton!) {
        showSearchBar(locationSearchBar)
    }

    func favoriteClicked(sender: UIButton!) {
        performSegueWithIdentifier("ShowFavorites", sender: sender)
    }
    
    func offlineClicked(sender: UIButton!) {
        performSegueWithIdentifier("ShowOffline", sender: sender)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWeb" {
            let vc = segue.destinationViewController as! LocationWebViewController
            let searchResult = sender as! SearchResult
            vc.pageId = searchResult.pageId
            vc.pageTitle = searchResult.pageTitle
        }
    }
}
