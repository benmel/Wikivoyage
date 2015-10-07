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
    var searchButtonWidthConstraint, searchButtonHeightConstraint, searchButtonEdgeConstraint: NSLayoutConstraint?
    
    var favoriteButton, offlineButton: UIButton!
    
    var resultsTable: UITableView!
    var searchResults = [SearchResult]()
    var lastRequestid: String!
    
    var didSetupContraints = false
    
    let searchBarStartingAlpha: CGFloat = 0
    let tableStartingAlpha: CGFloat = 0
    let searchButtonStartingAlpha: CGFloat = 1
    
    let searchBarEndingAlpha: CGFloat = 1
    let tableEndingAlpha: CGFloat = 1
    let searchButtonEndingAlpha: CGFloat = 0
    
    private let searchButtonTitle = "Search"
    private let favoriteButtonTitle = "Favorite Locations"
    private let offlineButtonTitle = "Offline Locations"
    
    private let allButtonTitleColor = UIColor.darkTextColor()
    private let allButtonCornerRadius: CGFloat = 5
    
    private let searchButtonColor = UIColor.redColor()
    private let otherButtonColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    
    private let searchButtonWidth: CGFloat = 300
    private let otherButtonWidth: CGFloat = 250
    private let searchButtonStartingHeight: CGFloat = 60
    private let searchButtonEndingHeight: CGFloat = 44
    private let otherButtonSpacing: CGFloat = 30
    private let tableRowHeight: CGFloat = 60
    
    let cellIdentifier = "TableCell"
    let placeholder = UIImage(named: "placeholder")!
    
    private let favoriteSegueIdentifier = "ShowFavorites"
    private let offlineSegueIdentifier = "ShowOffline"
    let webSegueIdentifier = "ShowWeb"
    
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
        locationSearchBar.alpha = searchBarStartingAlpha
        topView.addSubview(locationSearchBar)
    }
    
    func setupSearchButton() {
        searchButton = UIButton.buttonWithType(.Custom) as! UIButton
        searchButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchButton.setTitle(searchButtonTitle, forState: .Normal)
        searchButton.addTarget(self, action: "searchClicked:", forControlEvents: .TouchUpInside)
        
        searchButton.setTitleColor(allButtonTitleColor, forState: .Normal)
        searchButton.backgroundColor = searchButtonColor
        searchButton.layer.cornerRadius = allButtonCornerRadius
        
        topView.addSubview(searchButton)
    }
    
    func setupOtherButtons() {
        favoriteButton = UIButton.buttonWithType(.System) as! UIButton
        favoriteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        favoriteButton.setTitle(favoriteButtonTitle, forState: .Normal)
        favoriteButton.addTarget(self, action: "favoriteClicked:", forControlEvents: .TouchUpInside)
        
        favoriteButton.setTitleColor(allButtonTitleColor, forState: .Normal)
        favoriteButton.backgroundColor = otherButtonColor
        favoriteButton.layer.cornerRadius = allButtonCornerRadius
        
        bottomView.addSubview(favoriteButton)
        
        offlineButton = UIButton.buttonWithType(.System) as! UIButton
        offlineButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        offlineButton.setTitle(offlineButtonTitle, forState: .Normal)
        offlineButton.addTarget(self, action: "offlineClicked:", forControlEvents: .TouchUpInside)
        
        offlineButton.setTitleColor(allButtonTitleColor, forState: .Normal)
        offlineButton.backgroundColor = otherButtonColor
        offlineButton.layer.cornerRadius = allButtonCornerRadius
        
        bottomView.addSubview(offlineButton)
    }
    
    func setupTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.registerClass(SearchResultTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        resultsTable.alpha = tableStartingAlpha
        resultsTable.rowHeight = tableRowHeight
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
            
            favoriteButton.autoSetDimension(.Width, toSize: otherButtonWidth)
            favoriteButton.autoAlignAxisToSuperviewAxis(.Vertical)
            offlineButton.autoSetDimension(.Width, toSize: otherButtonWidth)
            offlineButton.autoAlignAxisToSuperviewAxis(.Vertical)
            let buttons = NSArray(array: [favoriteButton, offlineButton])
            buttons.autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: otherButtonSpacing)
            
            resultsTable.autoAlignAxisToSuperviewAxis(.Vertical)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            resultsTable.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: locationSearchBar)
            
            didSetupContraints = true
        }
        
        searchButtonWidthConstraint?.autoRemove()
        searchButtonHeightConstraint?.autoRemove()
        searchButtonEdgeConstraint?.autoRemove()
        
        if searchBarTop {
            searchButtonWidthConstraint = searchButton.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            searchButtonHeightConstraint = searchButton.autoSetDimension(.Height, toSize: searchButtonEndingHeight)
            searchButtonEdgeConstraint = searchButton.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        } else {
            searchButtonWidthConstraint = searchButton.autoSetDimension(.Width, toSize: searchButtonWidth)
            searchButtonHeightConstraint = searchButton.autoSetDimension(.Height, toSize: searchButtonStartingHeight)
            searchButtonEdgeConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Bottom)
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - User Interaction
    
    func searchClicked(sender: UIButton!) {
        showSearchBar(locationSearchBar)
    }

    func favoriteClicked(sender: UIButton!) {
        performSegueWithIdentifier(favoriteSegueIdentifier, sender: sender)
    }
    
    func offlineClicked(sender: UIButton!) {
        performSegueWithIdentifier(offlineSegueIdentifier, sender: sender)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == webSegueIdentifier {
            let vc = segue.destinationViewController as! LocationWebViewController
            let searchResult = sender as! SearchResult
            vc.pageId = searchResult.pageId
            vc.pageTitle = searchResult.pageTitle
        }
    }
}
