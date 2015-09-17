//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import MagicalRecord

class LocationWebViewController: WebViewController {

    var originalURLSet: Bool = false
    var originalURL: String?
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
    }
    
    override func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        super.webView(webView, didCommitNavigation: navigation)
        
        if !originalURLSet {
            originalURL = webView.URL?.absoluteString
            originalURLSet = true
        }
        
        if webView.URL?.absoluteString == originalURL {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    // Save page
    @IBAction func savePage(sender: AnyObject) {
        downloadText()
    }
    
    func downloadText() {
        Alamofire.request(.GET, "http://en.wikivoyage.org/w/api.php", parameters: ["action": "parse", "pageid": pageId, "prop": "text", "mobileformat": "", "noimages": "", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                
                // Check if it's already saved and if currently displaying Wikivoyage page
                let id = NSNumber(integer: self.pageId)
                if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
                    savedPage.title = self.pageTitle
                    savedPage.html = json["parse"]["text"]["*"].stringValue
                } else {
                    let savedPage = SavedPage.MR_createEntity()
                    savedPage.title = self.pageTitle
                    savedPage.id = self.pageId
                    savedPage.html = json["parse"]["text"]["*"].stringValue
                }
                
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
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
