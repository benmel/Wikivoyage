//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import MagicalRecord

protocol LocationWebViewControllerDelegate {
    func locationWebViewControllerDidUpdatePages(controller: LocationWebViewController)
}

class LocationWebViewController: StaticWebViewController {
    
    var delegate: LocationWebViewControllerDelegate?
    
    let favoriteSuccess = "Location added to favorites"
    let favoriteRemove = "Location removed from favorites"
    let offlineSuccess = "Location downloaded"
    let offlineRemove = "Offline location removed"
    let connectionError = "Connection error"
    let saveError = "Failed to save location"
    
    @IBOutlet var favoriteButton: UIBarButtonItem!
    @IBOutlet var downloadButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: - User Interaction
    
    @IBAction func favorite(sender: AnyObject) {
        favoritePage()
    }
    
    @IBAction func download(sender: AnyObject) {
        downloadPage()
    }
}
