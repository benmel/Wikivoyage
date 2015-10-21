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
    
    // MARK: - Initialization
    
    override func setupScriptNames() {
        super.setupScriptNames()
        applyScriptName = "ApplyOfflineScript"
    }
    
    override func setupButtons() {
        super.setupButtons()
        contentsButton.enabled = true
    }
    
    override func setupProgressView() {
        super.setupProgressView()
        progressView.hidden = true
    }
    
    override func requestURL() {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // MARK: - WebKit Navigation Delegate
    
    // Disable WebView navigation except for original load
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        navigationAction.navigationType == .Other ? decisionHandler(WKNavigationActionPolicy.Allow) : decisionHandler(WKNavigationActionPolicy.Cancel)
    }
    
    // MARK: - Helpers
    
    override func setContentsButtonState(message: WKScriptMessage) {
        contentsButton.enabled = true
    }
}
