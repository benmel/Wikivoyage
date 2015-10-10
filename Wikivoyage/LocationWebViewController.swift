//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit
import MapKit
import MagicalRecord

protocol LocationWebViewControllerDelegate {
    func locationWebViewControllerDidUpdatePages(controller: LocationWebViewController)
}

class LocationWebViewController: WebViewController {
    
    var pageId: Int!
    var pageTitle: String!
    
    var delegate: LocationWebViewControllerDelegate?
    var coordinate: CLLocationCoordinate2D?
    
    let favoriteSuccess = "Location added to favorites"
    let favoriteRemove = "Location removed from favorites"
    let offlineSuccess = "Location downloaded"
    let offlineRemove = "Offline location removed"
    let connectionError = "Connection error"
    let saveError = "Failed to save location"
    
    @IBOutlet var favoriteButton: UIBarButtonItem!
    @IBOutlet var downloadButton: UIBarButtonItem!
    
    private let segueIdentifier = "ShowWebExternal"
    private let mapIdentifier = "ShowMap"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCoordinatesNumberOfTimes(5)
    }
    
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
    @IBAction func showMap(sender: AnyObject) {
        performSegueWithIdentifier(mapIdentifier, sender: sender)
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
                    performSegueWithIdentifier(segueIdentifier, sender: url)
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let vc = segue.destinationViewController.topViewController as! ExternalWebViewController
            let url = sender as! NSURL
            vc.url = url
        } else if segue.identifier == mapIdentifier {
            let vc = segue.destinationViewController as! MapViewController
            vc.coordinate = coordinate
        }
    }
}
