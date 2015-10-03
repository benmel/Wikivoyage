//
//  WebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UIPopoverPresentationControllerDelegate {
    
    var webView: WKWebView!
    var style: String?
    var zoom: String?
    var webHeaders = [WebHeader]()
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var contentsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        getScripts()
        requestURL()
        contentsButton.enabled = false
    }
    
    func setupWebView() {
        // Add header script
        let config = WKWebViewConfiguration()
        let headerScriptURL = NSBundle.mainBundle().pathForResource("HeaderScript", ofType: "js")
        let headerScriptContent = String(contentsOfFile:headerScriptURL!, encoding:NSUTF8StringEncoding, error: nil)
        let headerScript = WKUserScript(source: headerScriptContent!, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(headerScript)
        config.userContentController.addScriptMessageHandler(self, name: "didGetHeadings")
        webView = WKWebView(frame: CGRectZero, configuration: config)
        
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
            contentsButton.enabled = true
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
    
    // WebView message handler
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        webHeaders.removeAll(keepCapacity: false)
        if message.name == "didGetHeadings" {
            if let headings = message.body as? [NSDictionary] {
                for h in headings {
                    if let id = h["id"] as? String, title = h["title"] as? String {
                        let webHeader = WebHeader(id: id, title: title)
                        webHeaders.append(webHeader)
                    }
                }
            }
        }
    }
    
    @IBAction func contents(sender: AnyObject) {
        let vc = WebHeadersTableViewController()
        let button = sender as! UIBarButtonItem
        vc.webHeaders = webHeaders
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.barButtonItem = button
        vc.preferredContentSize = CGSize(width: 180, height: 220)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func webHeaderSelected(notification: NSNotification) {
        let webHeader = notification.object as! WebHeader
        let scroll = "document.getElementById('\(webHeader.id)').scrollIntoView();"
        webView.evaluateJavaScript(scroll, completionHandler: nil)
    }
    
    // Progress view and title
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "webHeaderSelected:", name: "WebHeaderSelected", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "WebHeaderSelected", object: nil)
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
