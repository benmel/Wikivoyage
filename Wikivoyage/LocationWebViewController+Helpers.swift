//
//  LocationWebViewController+Helpers.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/9/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MagicalRecord
import MBProgressHUD

extension LocationWebViewController {
    
    // MARK: - Favorite
    
    func favoritePage() {
        let id = NSNumber(integer: pageId)
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
            updateFavoritePage(savedPage)
        } else {
            getThumbnailFavorite()
        }
    }
    
    func updateFavoritePage(page: SavedPage) {
        if page.favorite == true {
            if page.offline == false {
                page.MR_deleteEntity()
            } else {
                page.favorite = false
            }
            saveRemoveFavorite()
        } else {
            page.favorite = true
            saveAddFavorite()
        }
    }
    
    // Should use callback
    // Thumbnail functions are only called the first time a page is created
    func getThumbnailFavorite() {
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
                self.showAlert(self.connectionError)
            } else {
                let json = JSON(data!)
                let page = json["query"]["pages"][String(self.pageId)]
                let thumbnailURL = page["thumbnail"]["source"].string
                self.createFavorite(thumbnailURL)
            }
        }
    }
    
    func createFavorite(thumbnailURL: String?) {
        let newPage = SavedPage.MR_createEntity()
        newPage.title = pageTitle
        newPage.id = pageId
        newPage.favorite = true
        newPage.offline = false
        newPage.thumbnailURL = thumbnailURL
        saveAddFavorite()
    }
    
    // MARK: - Offline
    
    func downloadPage() {
        let id = NSNumber(integer: self.pageId)
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
            updateOfflinePage(savedPage)
        } else {
            downloadRequest()
        }
    }
    
    func updateOfflinePage(page: SavedPage) {
        if page.offline == true {
            if page.favorite == false {
                page.MR_deleteEntity()
            } else {
                page.offline = false
            }
            saveRemoveOffline()
        } else {
            downloadRequest()
        }
    }
    
    func downloadRequest() {
        let parameters: [String: AnyObject] = [
            "action": "parse",
            "format": "json",
            "pageid": pageId,
            "prop": "text",
            "mobileformat": "",
            "noimages": "",
            "disableeditsection": ""
        ]
        
        Alamofire.request(.GET, API.baseURL, parameters: parameters).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
                self.showAlert(self.connectionError)
            } else {
                let json = JSON(data!)
                let html = json["parse"]["text"]["*"].string
                let id = NSNumber(integer: self.pageId)
                if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: id) {
                    self.updateOfflinePageWithHTML(savedPage, html: html)
                } else {
                    self.getThumbnailOffline(html)
                }
            }
        }
    }
    
    func updateOfflinePageWithHTML(page: SavedPage, html: String?) {
        page.html = html
        page.offline = true
        saveAddOffline()
    }
    
    func getThumbnailOffline(html: String?) {
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
                self.showAlert(self.connectionError)
            } else {
                let json = JSON(data!)
                let page = json["query"]["pages"][String(self.pageId)]
                let thumbnailURL = page["thumbnail"]["source"].string
                self.createOffline(html, thumbnailURL: thumbnailURL)
            }
        }
    }
    
    func createOffline(html: String?, thumbnailURL: String?) {
        let newPage = SavedPage.MR_createEntity()
        newPage.title = pageTitle
        newPage.id = pageId
        newPage.html = html
        newPage.favorite = false
        newPage.offline = true
        newPage.thumbnailURL = thumbnailURL
        saveAddOffline()
    }
    
    // MARK: - Save
    
    func saveAddFavorite() {
        save(favoriteSuccess, button: favoriteButton, color: Color.fullButtonColor)
    }
    
    func saveRemoveFavorite() {
        save(favoriteRemove, button: favoriteButton, color: Color.emptyButtonColor)
    }
    
    func saveAddOffline() {
        save(offlineSuccess, button: downloadButton, color: Color.fullButtonColor)
    }
    
    func saveRemoveOffline() {
        save(offlineRemove, button: downloadButton, color: Color.emptyButtonColor)
    }
    
    // Completion can be called at wrong time, maybe use KVO for button color
    func save(alert: String, button: UIBarButtonItem, color: UIColor) {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({(success : Bool, error : NSError!) in
            if error != nil {
                NSLog("Error: \(error)")
            }
            
            if success {
                self.delegate?.locationWebViewControllerDidUpdatePages(self)
                self.showAlert(alert)
                self.setButtonColor(button, color: color)
            } else {
                self.showAlert(self.saveError)
            }
        })
    }
    
    // MARK: - Appearance
    
    func setButtonColor(button: UIBarButtonItem, color: UIColor) {
        button.tintColor = color
    }
    
    func showAlert(text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = text
        hud.mode = .Text
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 1)
    }
}
