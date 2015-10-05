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
        
    override func requestURL() {
        let request = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
        webView.loadRequest(request)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webView.goForward()
    }
}
