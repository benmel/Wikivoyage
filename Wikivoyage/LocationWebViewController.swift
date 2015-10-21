//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit
import MBProgressHUD

protocol LocationWebViewControllerDelegate: class {
    func locationWebViewControllerDidUpdatePages(controller: LocationWebViewController)
}

class LocationWebViewController: WebViewController {
    
    var pageId: Int!
    var pageTitle: String!
    var initialFavorite = false
    var initialOffline = false
    weak var delegate: LocationWebViewControllerDelegate?
    var selectedURL: NSURL!
    var attributeManager: AttributeManager!
    
    var hud: MBProgressHUD!
    var waitingForCoordinate = false
    var waitingForFavoriteAttributes = false
    var waitingForOfflineAttributes = false
    
    let favoriteSuccess = "Added to favorites"
    let favoriteRemove = "Removed from favorites"
    let offlineSuccess = "Downloaded"
    let offlineRemove = "Removed download"
    let connectionError = "Connection error"
    let saveError = "Failed to save"
    let otherError = "Something went wrong"
    
    var favoriteButton: UIBarButtonItem!
    var downloadButton: UIBarButtonItem!
    var mapButton: UIBarButtonItem!
    
    private let segueIdentifier = "ShowWebExternal"
    let mapIdentifier = "ShowMap"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHud()
        getAttributes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hud.hide(true)
        waitingForCoordinate = false
        waitingForFavoriteAttributes = false
        waitingForOfflineAttributes = false
    }
    
    // MARK: - Initialization
    
    override func setupButtons() {
        super.setupButtons()
        let starImage = initialFavorite ? Images.starToolbarSelectedImage : Images.starToolbarImage
        favoriteButton = UIBarButtonItem(image: starImage, style: .Plain, target: self, action: "favoriteClicked:")
        let downloadImage = initialOffline ? Images.downloadToolbarSelectedImage : Images.downloadToolbarImage
        downloadButton = UIBarButtonItem(image: downloadImage, style: .Plain, target: self, action: "downloadClicked:")
        mapButton = UIBarButtonItem(image: Images.mapImage, style: .Plain, target: self, action: "mapClicked:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbarItems = [downloadButton, flexibleSpace, favoriteButton, flexibleSpace, mapButton]
    }
    
    func setupHud() {
        hud = MBProgressHUD()
        hud.userInteractionEnabled = false
        view.addSubview(hud)
    }
    
    func getAttributes() {
        attributeManager = AttributeManager(pageId: pageId)
        attributeManager.delegate = self
        attributeManager.requestCoordinate()
        attributeManager.requestThumbnailURL()
        attributeManager.requestHtml()
    }
    
    // MARK: - User Interaction
    
    func favoriteClicked(sender: UIBarButtonItem) {
        favoritePage()
    }
    
    func downloadClicked(sender: UIBarButtonItem) {
        downloadPage()
    }
    
    func mapClicked(sender: UIBarButtonItem) {
        checkCoordinateStatus()
    }
    
    // MARK: - Initialization
    
    override func requestURL() {
        let path = pageTitle.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
        let url = NSURL(string: API.siteURL + path!)
        let request = NSURLRequest(URL: url!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: API.requestTimeout)
        webView.loadRequest(request)
    }
    
    // MARK: - WebKit Navigation Delegate
    
    // Open links in modal
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // Cancel navigation if request is for a different page, otherwise allow it
        if navigationAction.navigationType == .LinkActivated {
            if !isInternalLink(webView, navigationAction: navigationAction) {
                decisionHandler(WKNavigationActionPolicy.Cancel)
                if let url = navigationAction.request.URL {
                    selectedURL = url
                    performSegueWithIdentifier(segueIdentifier, sender: self)
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let externalWebViewController = segue.destinationViewController.topViewController as! ExternalWebViewController
            externalWebViewController.url = selectedURL
        } else if segue.identifier == mapIdentifier {
            let mapViewController = segue.destinationViewController as! MapViewController
            mapViewController.coordinate = attributeManager.coordinate
        }
    }
}

extension LocationWebViewController : AttributeManagerDelegate {
    func attributeManagerReceivedCoordinate(attributeManager: AttributeManager) {
        receivedCoordinate()
    }
    
    func attributeManagerReceivedFavoriteAttributes(attributeManager: AttributeManager) {
        receivedFavoriteAttributes()
    }
    
    func attributeManagerReceivedOfflineAttributes(attributeManager: AttributeManager) {
        receivedOfflineAttributes()
    }
}
