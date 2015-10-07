//
//  LocationWebViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/11/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MagicalRecord

class LocationWebViewController: StaticWebViewController {
    
    private let finalButtonColor = UIColor.redColor()
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: - User Interaction
    
    @IBAction func favorite(sender: AnyObject) {
        favoritePage()
        let button = sender as! UIBarButtonItem
        button.tintColor = finalButtonColor
    }
    
    @IBAction func download(sender: AnyObject) {
        downloadPage()
        let button = sender as! UIBarButtonItem
        button.tintColor = finalButtonColor
    }
    
    // MARK: - Helpers
    
    func favoritePage() {
        let id = NSNumber(integer: pageId)
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
            savedPage.favorite = true
        } else {
            let savedPage = SavedPage.MR_createEntity()
            savedPage.title = pageTitle
            savedPage.id = pageId
            savedPage.favorite = true
            savedPage.offline = false
        }
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        getThumbnail()
    }
    
    func downloadPage() {
        let parameters: [String: AnyObject] = [
            "action": "parse",
            "format": "json",
            "pageid": pageId,
            "prop": "text",
            "mobileformat": "",
            "noimages": ""
        ]
        
        Alamofire.request(.GET, API.baseURL, parameters: parameters).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                
                // Check if it's already saved and save HTML
                let id = NSNumber(integer: self.pageId)
                if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
                    savedPage.html = json["parse"]["text"]["*"].stringValue
                    savedPage.offline = true
                } else {
                    let savedPage = SavedPage.MR_createEntity()
                    savedPage.title = self.pageTitle
                    savedPage.id = self.pageId
                    savedPage.html = json["parse"]["text"]["*"].stringValue
                    savedPage.favorite = false
                    savedPage.offline = true
                }
                
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()

                self.getThumbnail()
            }
        }
    }
    
    func getThumbnail() {
        let parameters: [String: AnyObject] = [
            "action": "query",
            "format": "json",
            "pageids": pageId,
            "prop": "pageimages",
            "piprop": "thumbnail",
            "pithumbsize": Images.thumbnailSize,
            "pilimit": 1
        ]
        
        Alamofire.request(.GET, API.baseURL, parameters: parameters).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let page = json["query"]["pages"][String(self.pageId)]
                let thumbnailURL = page["thumbnail"]["source"].string
                
                // Save thumbnail to an existing page
                let id = NSNumber(integer: self.pageId)
                if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
                    savedPage.thumbnailURL = thumbnailURL
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                }
                
            }
        }
    }
}
