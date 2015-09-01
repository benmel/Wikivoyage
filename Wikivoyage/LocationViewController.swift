//
//  LocationViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/31/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class LocationViewController: UIViewController {

    var pageId: Int!
    var pageTitle: String!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = pageTitle
        // Set frame in viewWillLayoutSubviews
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        loadData()
    }
    
    func loadData() {
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: ["action": "parse", "pageid": pageId, "prop": "text", "mobileformat": "", "noimages": "", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let text = json["parse"]["text"]["*"]
                self.webView.loadHTMLString(text.string!, baseURL: nil)
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
