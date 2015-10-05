//
//  WebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit
import PureLayout

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UIPopoverPresentationControllerDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    @IBOutlet weak var contentsButton: UIBarButtonItem!
    
    var style: String?
    var zoom: String?
    var webHeaders = [WebHeader]()
    var didSetupConstraints = false

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupProgressView()
        setupButtons()
        getScripts()
        requestURL()
    }
    
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
    
    // MARK: Initialization
    
    func setupWebView() {
        // Add header script
        let config = WKWebViewConfiguration()
        let headerScriptURL = NSBundle.mainBundle().pathForResource("HeaderScript", ofType: "js")
        let headerScriptContent = String(contentsOfFile:headerScriptURL!, encoding:NSUTF8StringEncoding, error: nil)
        let headerScript = WKUserScript(source: headerScriptContent!, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(headerScript)
        config.userContentController.addScriptMessageHandler(self, name: "didGetHeadings")
        webView = WKWebView(frame: CGRectZero, configuration: config)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
        view.addSubview(webView)
    }
    
    func setupProgressView() {
        progressView = UIProgressView.newAutoLayoutView()
        progressView.progress = 0.0
        view.addSubview(progressView)
    }
    
    func setupButtons() {
        contentsButton.enabled = false
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
    
    // MARK: Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            webView.autoPinEdgesToSuperviewEdges()
            progressView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            progressView.autoPinEdgeToSuperviewEdge(.Leading)
            progressView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: WebKit Navigation Delegate
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        // Inject style and zoom CSS
        if isHostWikiURL(webView.URL?.host) {
            if style != nil { webView.evaluateJavaScript(style!, completionHandler: nil) }
            if zoom != nil { webView.evaluateJavaScript(zoom!, completionHandler: nil) }
            contentsButton.enabled = true
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        showError(error)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        showError(error)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // Reset progress view after loading page
        progressView.setProgress(0.0, animated: false)
    }
    
    // MARK: WebKit Script Message Handler
    
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
    
    // MARK: User Interaction
    
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
    
    func webHeaderSelected(notification: NSNotification) {
        let webHeader = notification.object as! WebHeader
        let scroll = "document.getElementById('\(webHeader.id)').scrollIntoView();"
        webView.evaluateJavaScript(scroll, completionHandler: nil)
    }
    
    // MARK: Popover Presentation Controller Delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: KVO
    
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
    
    // MARK: Helpers
    
    private func isHostWikiURL(url: String?) -> Bool {
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
    
    private func showError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}
