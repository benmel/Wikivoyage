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

    var mainView: MainView!
    var searchResults = [SearchResult]()
    
    private let favoriteSegueIdentifier = "ShowFavorites"
    private let offlineSegueIdentifier = "ShowOffline"
    let webSegueIdentifier = "ShowWeb"
    let cellIdentifier = "TableCell"
    
    let placeholder = UIImage(named: Images.placeholder)!
    var selectedSearchResult: SearchResult!
    var lastRequestid: String!
    
    private var didSetupConstraints = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        searchResults.removeAll(keepCapacity: false)
        mainView.resetSearchBar(false)
    }
    
    // MARK: - Initialization
    
    func setupView() {
        mainView = MainView(searchBarDelegate: self, tableViewDataSource: self, tableViewDelegate: self, cellIdentifier: cellIdentifier)
        mainView.delegate = self
        mainView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(mainView)
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            mainView.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == webSegueIdentifier {
            let locationWebViewController = segue.destinationViewController as! LocationWebViewController
            configureLocationWebViewController(locationWebViewController)
        }
    }
    
    func configureLocationWebViewController(locationWebViewController: LocationWebViewController) {
        locationWebViewController.pageId = selectedSearchResult.pageId
        locationWebViewController.pageTitle = selectedSearchResult.pageTitle
        locationWebViewController.title = selectedSearchResult.pageTitle
        
        let id = NSNumber(integer: selectedSearchResult.pageId)
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
            locationWebViewController.favoriteButton.tintColor = (savedPage.favorite == true) ? Color.fullButtonColor : Color.emptyButtonColor
            locationWebViewController.downloadButton.tintColor = (savedPage.offline == true) ? Color.fullButtonColor : Color.emptyButtonColor
        } else {
            locationWebViewController.favoriteButton.tintColor = Color.emptyButtonColor
            locationWebViewController.downloadButton.tintColor = Color.emptyButtonColor
        }
    }
}

// MARK: - Main View Delegate

extension MainViewController: MainViewDelegate {
    func favoriteButtonWasClicked(mainView: MainView, sender: UIButton!) {
        performSegueWithIdentifier(favoriteSegueIdentifier, sender: sender)
    }
    
    func offlineButtonWasClicked(mainView: MainView, sender: UIButton!) {
        performSegueWithIdentifier(offlineSegueIdentifier, sender: sender)
    }
}
