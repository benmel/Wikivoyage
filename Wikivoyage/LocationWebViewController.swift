//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit
import MagicalRecord
import MBProgressHUD

protocol LocationWebViewControllerDelegate: class {
    func locationWebViewControllerDidUpdatePages(controller: LocationWebViewController)
}

class LocationWebViewController: WebViewController {
    
    var pageId: Int!
    var pageTitle: String!
    weak var delegate: LocationWebViewControllerDelegate?
    var selectedURL: NSURL!
    var attributeManager: AttributeManager!
    
    var hud: MBProgressHUD!
    var waitingForCoordinate = false
    var waitingForFavoriteAttributes = false
    var waitingForOfflineAttributes = false
    
    let favoriteSuccess = "Location added to favorites"
    let favoriteRemove = "Location removed from favorites"
    let offlineSuccess = "Location downloaded"
    let offlineRemove = "Offline location removed"
    let connectionError = "Connection error"
    let saveError = "Failed to save location"
    let otherError = "Something went wrong"
    
    @IBOutlet var favoriteButton: UIBarButtonItem!
    @IBOutlet var downloadButton: UIBarButtonItem!
    
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
    
    @IBAction func favorite(sender: AnyObject) {
        favoritePage()
    }
    
    @IBAction func download(sender: AnyObject) {
        downloadPage()
    }
    @IBAction func showMap(sender: AnyObject) {
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
