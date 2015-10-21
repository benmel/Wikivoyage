//
//  MainView.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/12/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

protocol MainViewDelegate: class {
    func searchButtonWasClicked(mainView: MainView, sender: UIButton!)
    func favoriteButtonWasClicked(mainView: MainView, sender: UIButton!)
    func offlineButtonWasClicked(mainView: MainView, sender: UIButton!)
    func infoButtonWasClicked(mainView: MainView, sender: UIButton!)
}

class MainView: UIView {
    
    // MARK: - Views
    
    private var backgroundView: UIImageView!
    private var topView, bottomView: UIView!
    private var topSpace, bottomSpace: UIView!
    private var locationSearchBar: UISearchBar!
    private var searchButton: SearchButton!
    private var favoriteButton, offlineButton: MainButton!
    private var infoButton: UIButton!
    private var resultsTable: UITableView!
    
    // MARK: - View Constraints
    
    private var searchBarTop = false
    private var searchBarDimensionConstraint, searchBarEdgeConstraint: NSLayoutConstraint?
    private var searchButtonWidthConstraint, searchButtonEdgeConstraint, searchButtonLeadingConstraint, searchButtonTrailingConstraint: NSLayoutConstraint?
    private var didSetupConstraints = false
    
    // MARK: - Appearance
    
    private let searchBarStartingAlpha: CGFloat = 0
    private let tableStartingAlpha: CGFloat = 0
    private let searchButtonStartingAlpha: CGFloat = 1
    
    private let searchBarEndingAlpha: CGFloat = 1
    private let tableEndingAlpha: CGFloat = 1
    private let searchButtonEndingAlpha: CGFloat = 0
    private let searchButtonStartingCornerRadius: CGFloat = 20
    private let searchButtonEndingCornerRadius: CGFloat = 0
    
    private let placeholder = UIImage(named: Images.placeholder)!
    
    // MARK: - Text
    
    private let searchButtonTitle = "Search"
    private let favoriteButtonTitle = "Favorite Locations"
    private let offlineButtonTitle = "Offline Locations"
    
    // MARK: - Spacing
    
    private let searchButtonWidth: CGFloat = 320
    private let searchButtonHeight: CGFloat = 44
    private let searchButtonSpacing: CGFloat = 10
    private let otherButtonWidth: CGFloat = 250
    private let otherButtonHeight: CGFloat = 100
    private let otherButtonSpacing: CGFloat = 15
    private let infoButtonSpacing: CGFloat = 8
    private let tableRowHeight: CGFloat = 60
    
    // MARK: - Delegate
    
    weak var delegate: MainViewDelegate?

    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    init(searchBarDelegate: UISearchBarDelegate, tableViewDataSource: UITableViewDataSource, tableViewDelegate: UITableViewDelegate, cellIdentifier: String) {
        super.init(frame: CGRectZero)
        setupViews()
        locationSearchBar.delegate = searchBarDelegate
        resultsTable.dataSource = tableViewDataSource
        resultsTable.delegate = tableViewDelegate
        resultsTable.registerClass(LocationTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func setupViews() {
        setupBackgroundImage()
        setupTopBottom()
        setupSearchBar()
        setupSearchButton()
        setupOtherButtons()
        setupInfoButton()
        setupTable()
    }
    
    func setupBackgroundImage() {
        backgroundView = UIImageView.newAutoLayoutView()
        backgroundView.image = Images.backgroundImage
        backgroundView.contentMode = .ScaleAspectFill
        addSubview(backgroundView)
    }
    
    func setupTopBottom() {
        topView = UIView.newAutoLayoutView()
        bottomView = UIView.newAutoLayoutView()
        addSubview(topView)
        addSubview(bottomView)
        
        topSpace = UIView.newAutoLayoutView()
        bottomSpace = UIView.newAutoLayoutView()
        bottomView.addSubview(topSpace)
        bottomView.addSubview(bottomSpace)
    }
    
    func setupSearchBar() {
        locationSearchBar = UISearchBar.newAutoLayoutView()
        locationSearchBar.showsCancelButton = true
        locationSearchBar.alpha = searchBarStartingAlpha
        topView.addSubview(locationSearchBar)
    }
    
    func setupSearchButton() {
        searchButton = SearchButton.buttonWithType(.Custom) as! SearchButton
        searchButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchButton.addTarget(self, action: "searchClicked:", forControlEvents: .TouchUpInside)
        
        searchButton.title.text = searchButtonTitle
        searchButton.thumbnail.image = Images.searchImage
        searchButton.layer.cornerRadius = searchButtonStartingCornerRadius
        
        topView.addSubview(searchButton)
    }
    
    func setupOtherButtons() {
        favoriteButton = MainButton.buttonWithType(.Custom) as! MainButton
        favoriteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        favoriteButton.addTarget(self, action: "favoriteClicked:", forControlEvents: .TouchUpInside)
        
        favoriteButton.title.text = favoriteButtonTitle
        favoriteButton.thumbnail.image = Images.starImage
        
        bottomView.addSubview(favoriteButton)
        
        offlineButton = MainButton.buttonWithType(.Custom) as! MainButton
        offlineButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        offlineButton.addTarget(self, action: "offlineClicked:", forControlEvents: .TouchUpInside)
        
        offlineButton.title.text = offlineButtonTitle
        offlineButton.thumbnail.image = Images.downloadImage
        
        bottomView.addSubview(offlineButton)
    }
    
    func setupInfoButton() {
        infoButton = UIButton.buttonWithType(.InfoLight) as! UIButton
        infoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        infoButton.addTarget(self, action: "infoButtonClicked:", forControlEvents: .TouchUpInside)
        addSubview(infoButton)
    }
    
    func setupTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.alpha = tableStartingAlpha
        resultsTable.rowHeight = tableRowHeight
        // Disable separator lines for empty cells
        resultsTable.tableFooterView = UIView(frame: CGRectZero)
        
        addSubview(resultsTable)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            backgroundView.autoPinEdgesToSuperviewEdges()
            
            topView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            bottomView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            [topView, bottomView].autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Vertical, withFixedSpacing: 0)
            
            locationSearchBar.autoAlignAxisToSuperviewAxis(.Vertical)
            locationSearchBar.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            locationSearchBar.autoPinEdgeToSuperviewEdge(.Top)
            
            searchButton.autoAlignAxisToSuperviewAxis(.Vertical)
            
            topSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            topSpace.autoPinEdgeToSuperviewEdge(.Top)
            bottomSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            bottomSpace.autoPinEdgeToSuperviewEdge(.Bottom)
            topSpace.autoSetDimension(.Height, toSize: otherButtonSpacing, relation: .GreaterThanOrEqual)
            topSpace.autoMatchDimension(.Height, toDimension: .Height, ofView: bottomSpace)
            
            searchButton.autoSetDimension(.Height, toSize: searchButtonHeight)
            favoriteButton.autoSetDimension(.Width, toSize: otherButtonWidth)
            favoriteButton.autoAlignAxisToSuperviewAxis(.Vertical)
            offlineButton.autoSetDimension(.Width, toSize: otherButtonWidth)
            offlineButton.autoAlignAxisToSuperviewAxis(.Vertical)
            favoriteButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: topSpace)
            offlineButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: favoriteButton, withOffset: otherButtonSpacing)
            offlineButton.autoPinEdge(.Bottom, toEdge: .Top, ofView: bottomSpace)
            
            NSLayoutConstraint.autoSetPriority(750) {
                self.favoriteButton.autoSetDimension(.Height, toSize: otherButtonHeight, relation: .Equal)
            }
            favoriteButton.autoMatchDimension(.Height, toDimension: .Height, ofView: offlineButton)
            
            infoButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: infoButtonSpacing)
            infoButton.autoPinEdgeToSuperviewEdge(.Right, withInset: infoButtonSpacing)
            
            resultsTable.autoAlignAxisToSuperviewAxis(.Vertical)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            resultsTable.autoPinEdgeToSuperviewEdge(.Bottom)
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: locationSearchBar)
            
            didSetupConstraints = true
        }
        
        searchButtonWidthConstraint?.autoRemove()
        searchButtonEdgeConstraint?.autoRemove()
        searchButtonLeadingConstraint?.autoRemove()
        searchButtonTrailingConstraint?.autoRemove()
        
        if searchBarTop {
            searchButtonWidthConstraint = searchButton.autoMatchDimension(.Width, toDimension: .Width, ofView: topView)
            searchButtonEdgeConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Top)
        } else {
            NSLayoutConstraint.autoSetPriority(750) {
                self.searchButtonWidthConstraint = self.searchButton.autoSetDimension(.Width, toSize: self.searchButtonWidth)
            }
            searchButtonEdgeConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Bottom)
            searchButtonLeadingConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Leading, withInset: searchButtonSpacing, relation: .GreaterThanOrEqual)
            searchButtonTrailingConstraint = searchButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: searchButtonSpacing, relation: .GreaterThanOrEqual)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - User Interaction
    
    func searchClicked(sender: UIButton!) {
        delegate?.searchButtonWasClicked(self, sender: sender)
        showSearchBar(locationSearchBar)
    }
    
    func favoriteClicked(sender: UIButton!) {
        delegate?.favoriteButtonWasClicked(self, sender: sender)
    }
    
    func offlineClicked(sender: UIButton!) {
        delegate?.offlineButtonWasClicked(self, sender: sender)
    }
    
    func infoButtonClicked(sender: UIButton!) {
        delegate?.infoButtonWasClicked(self, sender: sender)
    }
}

// MARK: - Helpers

extension MainView {
    func dismissKeyboard() {
        locationSearchBar.resignFirstResponder()
        // Test if cancel button is needed
        enableCancelButton(locationSearchBar)
    }
    
    // Prevent cancel button from being disabled automatically
    func enableCancelButton(searchBar: UISearchBar) {
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKindOfClass(UIButton) {
                    let button = subview as! UIButton
                    button.enabled = true
                    return
                }
            }
        }
    }
    
    func resetSearchBar(animated: Bool) {
        locationSearchBar.text = ""
        dismissSearchBar(locationSearchBar, animated: animated)
    }
    
    func reloadTableRows() {
        self.resultsTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func showSearchBar(searchBar: UISearchBar) {
        searchBarTop = true
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.3,
            animations: {
                searchBar.becomeFirstResponder()
                self.layoutIfNeeded()
            }, completion: { finished in
                UIView.animateWithDuration(0.2,
                    animations: {
                        searchBar.alpha = self.searchBarEndingAlpha
                        self.resultsTable.alpha = self.tableEndingAlpha
                        self.searchButton.alpha = self.searchButtonEndingAlpha
                        self.searchButton.layer.cornerRadius = self.searchButtonEndingCornerRadius
                    }
                )
            }
        )
    }
    
    func dismissSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBarTop = false
        
        if animated {
            UIView.animateWithDuration(0.2,
                animations: {
                    searchBar.alpha = self.searchBarStartingAlpha
                    self.resultsTable.alpha = self.tableStartingAlpha
                    self.searchButton.alpha = self.searchButtonStartingAlpha
                    self.searchButton.layer.cornerRadius = self.searchButtonStartingCornerRadius
                }, completion:  { finished in
                    self.setNeedsUpdateConstraints()
                    self.updateConstraintsIfNeeded()
                    UIView.animateWithDuration(0.3,
                        animations: {
                            searchBar.resignFirstResponder()
                            self.layoutIfNeeded()
                        }
                    )
                }
            )
        } else {
            searchBar.resignFirstResponder()
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
            layoutIfNeeded()
            searchBar.alpha = searchBarStartingAlpha
            resultsTable.alpha = tableStartingAlpha
            searchButton.alpha = searchButtonStartingAlpha
            searchButton.layer.cornerRadius = searchButtonStartingCornerRadius
        }
    }
}