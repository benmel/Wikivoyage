//
//  OfflineWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/24/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class OfflineWebViewController: WebViewController {

    var html: String!
    var offline: String?
    var webViewLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.hidden = true
    }
    
    override func requestURL() {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    override func getScripts() {
        super.getScripts()
        
        if let styleScriptURL = NSBundle.mainBundle().pathForResource("OfflineScript", ofType: "js") {
            offline = String(contentsOfFile:styleScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
    }
    
    // Disable WebView navigation
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if !webViewLoaded {
            decisionHandler(WKNavigationActionPolicy.Allow)
        } else {
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
    }
    
    override func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        super.webView(webView, didFinishNavigation: navigation)
        webViewLoaded = true
    }
    
    override func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        super.webView(webView, didCommitNavigation: navigation)
        // Inject style and zoom CSS
        if style != nil { webView.evaluateJavaScript(style!, completionHandler: nil) }
        if offline != nil { webView.evaluateJavaScript(offline!, completionHandler: nil) }
    }
}
