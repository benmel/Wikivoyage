//
//  StaticWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/24/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class StaticWebViewController: WebViewController {

    var pageId: Int!
    var pageTitle: String!
        
    override func requestURL() {
        let path = pageTitle.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: "http://en.m.wikivoyage.com/wiki/"+path!)
        let request = NSURLRequest(URL: url!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
        webView.loadRequest(request)
    }
    
    // Open links in modal
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // Cancel navigation if request is for a different page, otherwise allow it
        if navigationAction.navigationType == .LinkActivated {
            if !isInternalLink(webView, navigationAction: navigationAction) {
                decisionHandler(WKNavigationActionPolicy.Cancel)
                if let url = navigationAction.request.URL {
                    self.performSegueWithIdentifier("ShowWebExternal", sender: url)
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func isInternalLink(webView: WKWebView, navigationAction: WKNavigationAction) -> Bool {
        if let currentURL = webView.URL, requestURL = navigationAction.request.URL {
            if let currentScheme = currentURL.scheme, currentHost = currentURL.host, currentPathComponents = currentURL.pathComponents as? [String], requestScheme = requestURL.scheme, requestHost = requestURL.host, requestPathComponents = requestURL.pathComponents as? [String] {
                // An internal link has the same scheme, host and path components
                if currentScheme == requestScheme && currentHost == requestHost && areArraysEqual(firstArray: currentPathComponents, secondArray: requestPathComponents) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func areArraysEqual(firstArray a: [String], secondArray b: [String]) -> Bool {
        if a.count != b.count {
            return false
        }
        
        for i in 0..<a.count {
            if a[i] != b[i] {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowWebExternal" {
            let url = sender as! NSURL
            let vc = segue.destinationViewController.topViewController as! ExternalWebViewController
            vc.url = url
        }
    }
}
