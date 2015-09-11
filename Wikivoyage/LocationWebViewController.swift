//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import WebKit

class LocationWebViewController: UIViewController, WKNavigationDelegate {

    var pageId: Int!
    var pageTitle: String!
    var webView: WKWebView!
    
    var style: String?
    var zoom: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getScripts()
        setupWebView()
        requestURL()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame = self.view.frame        
    }
    
    // Setup methods
    func getScripts() {
        if let styleScriptURL = NSBundle.mainBundle().pathForResource("StyleScript", ofType: "js") {
            style = String(contentsOfFile:styleScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
        
        if let zoomScriptURL = NSBundle.mainBundle().pathForResource("ZoomScript", ofType: "js") {
            zoom = String(contentsOfFile:zoomScriptURL, encoding:NSUTF8StringEncoding, error: nil)
        }
    }
    
    func setupWebView() {
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    
    func requestURL() {
        let newTitle = pageTitle.stringByReplacingOccurrencesOfString(" ", withString: "_", options: nil, range: nil)
        let url = NSURL(string: "http://en.m.wikivoyage.com/wiki/"+newTitle)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    // Webview delegate
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        if let url = webView.URL, host = url.host {
            if host == "en.m.wikivoyage.org" {
                if style != nil { webView.evaluateJavaScript(style!, completionHandler: nil) }
                if zoom != nil { webView.evaluateJavaScript(zoom!, completionHandler: nil) }
            }
        }
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
