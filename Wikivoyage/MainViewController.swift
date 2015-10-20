//
//  MainViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/28/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout
import MBProgressHUD
import Alamofire

class MainViewController: UIViewController {

    var mainView: MainView!
    var hud: MBProgressHUD!
    
    var searchResults = [SearchResult]()
    
    private let favoriteSegueIdentifier = "ShowFavorites"
    private let offlineSegueIdentifier = "ShowOffline"
    let webSegueIdentifier = "ShowWeb"
    let cellIdentifier = "TableCell"
    
    let placeholder = UIImage(named: Images.placeholder)!
    var selectedSearchResult: SearchResult!
    var lastRequestid: String!
    var lastRequest: Request?
    
    private let hudYOffset: Float = -60
    private let hudMinTime: Float = 0.3
    
    private var didSetupConstraints = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHud()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.addSubview(hud)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hud.removeFromSuperview()
        lastRequest?.cancel()
        emptyTable()
        mainView.resetSearchBar(false)
    }
    
    // MARK: - Initialization
    
    func setupView() {
        mainView = MainView(searchBarDelegate: self, tableViewDataSource: self, tableViewDelegate: self, cellIdentifier: cellIdentifier)
        mainView.delegate = self
        mainView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(mainView)
    }
    
    func setupHud() {
        hud = MBProgressHUD()
        hud.yOffset = hudYOffset
        hud.minShowTime = hudMinTime
        hud.userInteractionEnabled = false
    }
    
    // MARK: - Layout
    
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
            locationWebViewController.initialFavorite = savedPage.favorite.boolValue
            locationWebViewController.initialOffline = savedPage.offline.boolValue
        }
    }
    
    // MARK: - Helpers
    
    func emptyTable() {
        searchResults.removeAll(keepCapacity: false)
        mainView.reloadTableRows()
    }
}

// MARK: - Main View Delegate

extension MainViewController: MainViewDelegate {
    func searchButtonWasClicked(mainView: MainView, sender: UIButton!) {
        emptyTable()
    }
    
    func favoriteButtonWasClicked(mainView: MainView, sender: UIButton!) {
        performSegueWithIdentifier(favoriteSegueIdentifier, sender: sender)
    }
    
    func offlineButtonWasClicked(mainView: MainView, sender: UIButton!) {
        performSegueWithIdentifier(offlineSegueIdentifier, sender: sender)
    }
    
    func infoButtonWasClicked(mainView: MainView, sender: UIButton!) {
        let vc = InfoViewController()
        presentViewController(vc, animated: true, completion: nil)
    }
}
