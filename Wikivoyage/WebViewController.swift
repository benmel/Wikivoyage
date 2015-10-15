//
//  WebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit
import PureLayout

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    var configuration: WKWebViewConfiguration!
    var progressView: UIProgressView!
    @IBOutlet weak var contentsButton: UIBarButtonItem!
    
    var script: WKUserScript!
    var scriptName: String!
    var applyScriptName: String!
    
    var webHeaders = [WebHeader]()
    var webHeadersLoaded = false
    
    var didSetupConstraints = false
    
    private let progressKey = "estimatedProgress"
    private let titleKey = "title"
    private let webHeaderName = "WebHeaderSelected"
    
    private let didGetIsWikiHost = "didGetIsWikiHost"
    private let didGetHeaders = "didGetHeaders"
    
    private let popoverWidth = 180
    private let popoverHeight = 220
    
    private let progressViewColor = UIColor(red: 27/255, green: 163/255, blue: 156/255, alpha: 1)

    // MARK: - View Lifecycle
    
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
        webView.addObserver(self, forKeyPath: progressKey, options: .New, context: nil)
        webView.addObserver(self, forKeyPath: titleKey, options: .New, context: nil)
        configuration.userContentController.addScriptMessageHandler(self, name: didGetIsWikiHost)
        configuration.userContentController.addScriptMessageHandler(self, name: didGetHeaders)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "webHeaderSelected:", name: webHeaderName, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: progressKey)
        webView.removeObserver(self, forKeyPath: titleKey)
        configuration.userContentController.removeScriptMessageHandlerForName(didGetIsWikiHost)
        configuration.userContentController.removeScriptMessageHandlerForName(didGetHeaders)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: webHeaderName, object: nil)
    }
    
    // MARK: - Initialization
    
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
        configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(script)
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        webView.navigationDelegate = self
        
        view.addSubview(webView)
    }
    
    func setupProgressView() {
        progressView = UIProgressView.newAutoLayoutView()
        progressView.progress = 0.0
        progressView.tintColor = progressViewColor
        view.addSubview(progressView)
    }
    
    func setupButtons() {
        contentsButton.enabled = false
    }
        
    // Override this method
    func requestURL() {
    }
    
    // MARK: - Layout
    
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

    
    // MARK: - User Interaction
    
    @IBAction func contents(sender: AnyObject) {
        // Check that headers are loaded and button is enabled
        let button = sender as! UIBarButtonItem
        if webHeadersLoaded && button.enabled {
            let vc = WebHeadersTableViewController()
            let button = sender as! UIBarButtonItem
            vc.webHeaders = webHeaders
            vc.notificationName = webHeaderName
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.barButtonItem = button
            vc.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func webHeaderSelected(notification: NSNotification) {
        let webHeader = notification.object as! WebHeader
        let scroll = "document.getElementById('\(webHeader.id)').scrollIntoView();"
        webView.evaluateJavaScript(scroll, completionHandler: nil)
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == progressKey {
            // Bug where estimatedProgress = 0.1 even for pages that are already loaded
            if webView.estimatedProgress > 0.1 && webView.estimatedProgress < 1.0 {
                // Show progress if it's between 0.1 and 1.0
                progressView.hidden = false
                progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            } else {
                progressView.hidden = true
            }
        } else if keyPath == titleKey {
            if let newTitle = webView.title?.stringByReplacingOccurrencesOfString(" – Travel guide at Wikivoyage", withString: "", options: nil, range: nil) {
                title = newTitle
            } else {
                title = ""
            }
        }
    }
}

// MARK: - WebKit Navigation Delegate

extension WebViewController: WKNavigationDelegate {
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
    
    // MARK: - Helpers
    
    private func showError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - WebKit Script Message Handler

extension WebViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == didGetIsWikiHost {
            setContentsButtonState(message)
        } else if message.name == didGetHeaders {
            updateHeaders(message)
        }
    }
    
    // MARK: - Helpers
    
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

// MARK: - Popover Presentation Controller Delegate

extension WebViewController: UIPopoverPresentationControllerDelegate {    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!, traitCollection: UITraitCollection!) -> UIModalPresentationStyle {
        return .None
    }
}
