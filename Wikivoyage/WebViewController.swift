//
//  WebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!
    var style: String?
    var zoom: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        getScripts()
        requestURL()
    }
    
    func setupWebView() {
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
        self.view.sendSubviewToBack(webView)
        
        // Edge contraints
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
        self.view.addConstraints([height, width])
    }
    
    func getScripts() {
        if let styleScriptURL = NSBundle.mainBundle().pathForResource("StyleScript", ofType: "js") {
            style = String(contentsOfFile:styleScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
        
        if let zoomScriptURL = NSBundle.mainBundle().pathForResource("ZoomScript", ofType: "js") {
            zoom = String(contentsOfFile:zoomScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
    }
    
    // Override this method
    func requestURL() {
    }
    
    // WebView delegate
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        // Inject style and zoom CSS
        if isHostWikiURL(webView.URL?.host) {
            if style != nil { webView.evaluateJavaScript(style!, completionHandler: nil) }
            if zoom != nil { webView.evaluateJavaScript(zoom!, completionHandler: nil) }
        }
    }
    
    func isHostWikiURL(url: String?) -> Bool {
        if let components = url?.componentsSeparatedByString(".") {
            if contains(components, "wikivoyage") || contains(components, "wikipedia") || contains(components, "wikimedia") && contains(components, "org") {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        // Error message
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // Reset progress view after loading page
        progressView.setProgress(0.0, animated: false)
    }
    
    // Progress view and title
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "estimatedProgress") {
            // Bug where estimatedProgress = 0.1 even for pages that are already loaded
            if webView.estimatedProgress > 0.1 && webView.estimatedProgress < 1.0 {
                // Show progress if it's between 0.1 and 1.0
                progressView.hidden = false
                progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            } else {
                progressView.hidden = true
            }
        }
        
        if (keyPath == "title") {
            if let newTitle = webView.title?.stringByReplacingOccurrencesOfString(" – Travel guide at Wikivoyage", withString: "", options: nil, range: nil) {
                self.title = newTitle
            } else {
                self.title = ""
            }
        }
    }
}
