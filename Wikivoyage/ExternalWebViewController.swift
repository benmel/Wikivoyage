//
//  ExternalWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/24/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Foundation

class ExternalWebViewController: WebViewController {
    
    var url: NSURL!

    // MARK: - Initialization
    
    override func setupWebView() {
        super.setupWebView()
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func requestURL() {
        let request = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: API.requestTimeout)
        webView.loadRequest(request)
    }
    
    // MARK: - User Interaction
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webView.goForward()
    }
}
