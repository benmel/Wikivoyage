//
//  WebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    var pageId: Int!
    var pageTitle: String!
    var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!
    
    var style: String?
    var zoom: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupGestureRecognizer()
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
        
        if let zoomScriptURL = NSBundle.mainBundle().pathForResource("ZoomScript", ofType: "js") {
            zoom = String(contentsOfFile:zoomScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
    }
    
    func requestURL() {
        let newTitle = pageTitle.stringByReplacingOccurrencesOfString(" ", withString: "_", options: nil, range: nil)
        let url = NSURL(string: "http://en.m.wikivoyage.com/wiki/"+newTitle)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    // WebView delegate
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Show nav bar when going to new page
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
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
    
    // Progress view and navigation controller
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        
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
        
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        
        // Reset navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        if self.navigationController != nil {
            if self.navigationController!.respondsToSelector("interactivePopGestureRecognizer") {
                self.navigationController?.interactivePopGestureRecognizer.enabled = true
            }
        }
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
