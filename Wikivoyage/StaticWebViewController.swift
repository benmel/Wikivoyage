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
    var webViewLoaded: Bool = false
        
    override func requestURL() {
        let path = pageTitle.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: "http://en.m.wikivoyage.com/wiki/"+path!)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    // Open links in modal
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if !webViewLoaded {
            decisionHandler(WKNavigationActionPolicy.Allow)
        } else {
            decisionHandler(WKNavigationActionPolicy.Cancel)
            if let url = navigationAction.request.URL {
                self.performSegueWithIdentifier("ShowExternalPage", sender: url)
            }
        }
    }
    
    override func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        super.webView(webView, didFinishNavigation: navigation)
        webViewLoaded = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowExternalPage" {
            let url = sender as! NSURL
            let vc = segue.destinationViewController.topViewController as! ExternalWebViewController
            vc.url = url
        }
    }
}
