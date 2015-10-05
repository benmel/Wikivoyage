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
    var webViewLoaded: Bool = false
    
    override func setupScriptNames() {
        super.setupScriptNames()
        applyScriptName = "ApplyOfflineScript"
    }
    
    override func setupProgressView() {
        super.setupProgressView()
        progressView.hidden = true
    }
    
    override func setupButtons() {
        super.setupButtons()
        contentsButton.enabled = true
    }
    
    override func requestURL() {
        webView.loadHTMLString(html, baseURL: nil)
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
    
    override func setContentsButtonState(message: WKScriptMessage) {
        contentsButton.enabled = true
    }
}
