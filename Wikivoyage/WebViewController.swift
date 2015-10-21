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
    
    var contentsButton: UIBarButtonItem!
    var progressView: UIProgressView!
    
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
        setupNavBar()
        setupWebView()
        setupButtons()
        setupProgressView()
        requestURL()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: progressKey, options: .New, context: nil)
        webView.addObserver(self, forKeyPath: titleKey, options: .New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "webHeaderSelected:", name: webHeaderName, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: progressKey)
        webView.removeObserver(self, forKeyPath: titleKey)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: webHeaderName, object: nil)
    }
    
    deinit {
        configuration.userContentController.removeScriptMessageHandlerForName(didGetIsWikiHost)
        configuration.userContentController.removeScriptMessageHandlerForName(didGetHeaders)
    }
    
    // MARK: - Initialization
    
    func setupNavBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
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
        configuration.userContentController.addScriptMessageHandler(LeakAvoider(delegate: self), name: didGetIsWikiHost)
        configuration.userContentController.addScriptMessageHandler(LeakAvoider(delegate: self), name: didGetHeaders)
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        webView.navigationDelegate = self
        
        view.addSubview(webView)
    }
    
    func setupButtons() {
        contentsButton = UIBarButtonItem(image: Images.listImage, style: .Plain, target: self, action: "showContents:")
        contentsButton.enabled = false
        navigationItem.rightBarButtonItem = contentsButton
    }
        
    func setupProgressView() {
        progressView = UIProgressView.newAutoLayoutView()
        progressView.progress = 0.0
        progressView.tintColor = progressViewColor
        progressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(progressView)
    }
    
    // Override this method
    func requestURL() {
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            webView.autoPinEdgeToSuperviewEdge(.Top)
            webView.autoPinEdgeToSuperviewEdge(.Leading)
            webView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            // In iOS 9 need to avoid putting web view under toolbar
            if System.version >= 9 {
                webView.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
            } else {
                webView.autoPinEdgeToSuperviewEdge(.Bottom)
            }
            
            progressView.autoPinEdgeToSuperviewEdge(.Top)
            progressView.autoPinEdgeToSuperviewEdge(.Leading)
            progressView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }

    
    // MARK: - User Interaction
    
    func showContents(sender: UIBarButtonItem) {
        // Check that headers are loaded and button is enabled
        if webHeadersLoaded && sender.enabled {
            let vc = WebHeadersTableViewController()
            vc.webHeaders = webHeaders
            vc.notificationName = webHeaderName
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.barButtonItem = sender
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
