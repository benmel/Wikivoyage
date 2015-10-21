//
//  ExternalWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/24/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class ExternalWebViewController: WebViewController {
    
    var url: NSURL!
    
    var doneButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    private let fixedWidth: CGFloat = 60

    // MARK: - Initialization
    
    override func setupWebView() {
        super.setupWebView()
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func setupButtons() {
        super.setupButtons()
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneClicked:")
        navigationItem.leftBarButtonItem = doneButton
        backButton = UIBarButtonItem(image: Images.backImage, style: .Plain, target: self, action: "backClicked:")
        forwardButton = UIBarButtonItem(image: Images.forwardImage, style: .Plain, target: self, action: "forwardClicked:")
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpace.width = fixedWidth
        toolbarItems = [backButton, fixedSpace, forwardButton]
    }
    
    override func requestURL() {
        let request = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: API.requestTimeout)
        webView.loadRequest(request)
    }
    
    // MARK: - User Interaction
    
    func doneClicked(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backClicked(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func forwardClicked(sender: UIBarButtonItem) {
        webView.goForward()
    }
}
