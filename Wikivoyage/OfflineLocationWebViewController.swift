//
//  OfflineLocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import WebKit

class OfflineLocationWebViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    var html: String!
    var webView: WKWebView!
    var webViewLoaded: Bool = false
    
    var style: String?
    var offline: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupGestureRecognizer()
        getScripts()
        requestURL()
    }
    
    func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
        
        // Edge contraints
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
        self.view.addConstraints([height, width])
    }
    
    func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "webViewTapped:")
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTapsRequired = 2
        self.webView.addGestureRecognizer(gestureRecognizer)
    }
    
    func getScripts() {
        if let styleScriptURL = NSBundle.mainBundle().pathForResource("StyleScript", ofType: "js") {
            style = String(contentsOfFile:styleScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
        
        if let styleScriptURL = NSBundle.mainBundle().pathForResource("OfflineScript", ofType: "js") {
            offline = String(contentsOfFile:styleScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
    }
    
    func requestURL() {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // WebView delegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if !webViewLoaded {
            decisionHandler(WKNavigationActionPolicy.Allow)
            webViewLoaded = true
        } else {
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        // Inject style and zoom CSS
        if style != nil { webView.evaluateJavaScript(style!, completionHandler: nil) }
        if offline != nil { webView.evaluateJavaScript(offline!, completionHandler: nil) }
    }
    
    // Gesture recognizer
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func webViewTapped(recognizer: UITapGestureRecognizer) {
        if let navigationController = self.navigationController {
            let change = !navigationController.navigationBarHidden
            navigationController.setNavigationBarHidden(change, animated: true)
        }
    }
    
    // Navigation controller
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    // Disabling back swipe gesture only works in viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.navigationController != nil {
            if self.navigationController!.respondsToSelector("interactivePopGestureRecognizer") {
                self.navigationController?.interactivePopGestureRecognizer.enabled = false
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        if self.navigationController != nil {
            if self.navigationController!.respondsToSelector("interactivePopGestureRecognizer") {
                self.navigationController?.interactivePopGestureRecognizer.enabled = true
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController!.navigationBarHidden
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
