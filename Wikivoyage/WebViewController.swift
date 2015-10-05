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
    
    var script: WKUserScript!
    var scriptName: String!
    var applyScriptName: String!
    
    var webHeaders = [WebHeader]()
    var webHeadersLoaded = false
    var didSetupConstraints = false

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScriptNames()
        setupScript()
        setupWebView()
        setupProgressView()
        setupButtons()
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
    
    func setupScriptNames() {
        scriptName = "Script"
        applyScriptName = "ApplyOnlineScript"
    }
    
    func setupScript() {
        let scriptURL = NSBundle.mainBundle().pathForResource(scriptName, ofType: "js")
        let scriptContent = String(contentsOfFile:scriptURL!, encoding:NSUTF8StringEncoding, error: nil)
        
        let applyScriptURL = NSBundle.mainBundle().pathForResource(applyScriptName, ofType: "js")
        let applyContent = String(contentsOfFile:applyScriptURL!, encoding:NSUTF8StringEncoding, error: nil)
        
        let finalScriptContent = scriptContent! + applyContent!
        
        script = WKUserScript(source: finalScriptContent, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    }
    
    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(script)
        config.userContentController.addScriptMessageHandler(self, name: "didGetIsWikiHost")
        config.userContentController.addScriptMessageHandler(self, name: "didGetHeaders")
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
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webHeadersLoaded = false
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        showError(error)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // Reset progress view after loading page
        progressView.setProgress(0.0, animated: false)
    }
    
    // MARK: WebKit Script Message Handler
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == "didGetIsWikiHost" {
            setContentsButtonState(message)
        } else if message.name == "didGetHeaders" {
            updateHeaders(message)
        }
    }
    
    // MARK: User Interaction
    
    @IBAction func contents(sender: AnyObject) {
        // Check that headers are loaded and button is enabled
        let button = sender as! UIBarButtonItem
        if webHeadersLoaded && button.enabled {
            let vc = WebHeadersTableViewController()
            let button = sender as! UIBarButtonItem
            vc.webHeaders = webHeaders
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.barButtonItem = button
            vc.preferredContentSize = CGSize(width: 180, height: 220)
            presentViewController(vc, animated: true, completion: nil)
        }
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
    
    private func showError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setContentsButtonState(message: WKScriptMessage) {
        if let isWikiHost = message.body as? Bool {
            contentsButton.enabled = isWikiHost
        } else {
            contentsButton.enabled = false
        }
    }
    
    private func updateHeaders(message: WKScriptMessage) {
        webHeaders.removeAll(keepCapacity: false)
        if let headers = message.body as? [NSDictionary] {
            for h in headers {
                if let id = h["id"] as? String, title = h["title"] as? String {
                    let webHeader = WebHeader(id: id, title: title)
                    webHeaders.append(webHeader)
                }
            }
        }
        webHeadersLoaded = true
    }
}
