//
//  LocationWebViewController+Helpers.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/9/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import MagicalRecord
import MBProgressHUD
import WebKit

extension LocationWebViewController {
    
    // MARK: - Web
    
    func isInternalLink(webView: WKWebView, navigationAction: WKNavigationAction) -> Bool {
        if let currentURL = webView.URL, requestURL = navigationAction.request.URL {
            if let currentScheme = currentURL.scheme, currentHost = currentURL.host, currentPathComponents = currentURL.pathComponents as? [String], requestScheme = requestURL.scheme, requestHost = requestURL.host, requestPathComponents = requestURL.pathComponents as? [String] {
                // An internal link has the same scheme, host and path components
                if currentScheme == requestScheme && currentHost == requestHost && areArraysEqual(firstArray: currentPathComponents, secondArray: requestPathComponents) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func areArraysEqual(firstArray a: [String], secondArray b: [String]) -> Bool {
        if a.count != b.count {
            return false
        }
        for i in 0..<a.count {
            if a[i] != b[i] {
                return false
            }
        }
        return true
    }
    
    // MARK: - Coordinate
    
    func checkCoordinateStatus() {
        switch attributeManager.coordinateState {
        case .Succeeded:
            showMap()
        case .Failed:
            showAlert(self.connectionError)
        case .Attempting:
            hud.show(true)
            waitingForCoordinate = true
        case .Unattempted:
            showAlert(self.otherError)
        }
    }
    
    func receivedCoordinate() {
        if waitingForCoordinate {
            if !waitingForFavoriteAttributes && !waitingForOfflineAttributes {
                hud.hide(true)
            }
            
            switch attributeManager.coordinateState {
            case .Succeeded:
                showMap()
            case .Failed:
                showAlert(self.connectionError)
            case .Attempting:
                showAlert(self.otherError)
            case .Unattempted:
                showAlert(self.otherError)
            }

            waitingForCoordinate = false
        }
    }
    
    func showMap() {
        performSegueWithIdentifier(mapIdentifier, sender: self)
    }
    
    // MARK: - Favorite
    
    func favoritePage() {
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: NSNumber(integer: self.pageId)) {
            updateFavoritePage(savedPage)
        } else {
            checkFavoriteStatus()
        }
    }
    
    func updateFavoritePage(page: SavedPage) {
        if page.favorite == true {
            if page.offline == false {
                page.MR_deleteEntity()
            } else {
                page.favorite = false
            }
            save(favoriteRemove)
        } else {
            page.favorite = true
            save(favoriteSuccess)
        }
    }
    
    func checkFavoriteStatus() {
        switch attributeManager.favoriteState {
        case .Succeeded:
            createFavoritePage()
        case .Failed:
            showAlert(self.connectionError)
        case .Attempting:
            hud.show(true)
            waitingForFavoriteAttributes = true
        case .Unattempted:
            showAlert(self.otherError)
        }
    }
    
    func createFavoritePage() {
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: NSNumber(integer: self.pageId)) {
            savedPage.favorite = true
        } else {
            let newPage = SavedPage.MR_createEntity()
            newPage.title = pageTitle
            newPage.id = pageId
            newPage.favorite = true
            newPage.offline = false
            newPage.thumbnailURL = attributeManager.thumbnailURL
        }
        save(favoriteSuccess)
    }
    
    func receivedFavoriteAttributes() {
        if waitingForFavoriteAttributes {
            if !waitingForCoordinate && !waitingForOfflineAttributes {
                hud.hide(true)
            }
            
            switch attributeManager.favoriteState {
            case .Succeeded:
                createFavoritePage()
            case .Failed:
                showAlert(self.connectionError)
            case .Attempting:
                showAlert(self.otherError)
            case .Unattempted:
                showAlert(self.otherError)
            }
            
            waitingForFavoriteAttributes = false
        }
    }
    
    // MARK: - Offline
    
    func downloadPage() {
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: NSNumber(integer: self.pageId)) {
            updateOfflinePage(savedPage)
        } else {
            checkOfflineStatus()
        }
    }
    
    func updateOfflinePage(page: SavedPage) {
        if page.offline == true {
            if page.favorite == false {
                page.MR_deleteEntity()
            } else {
                page.offline = false
            }
            save(offlineRemove)
        } else {
            checkOfflineStatus()
        }
    }
    
    func checkOfflineStatus() {
        switch attributeManager.offlineState {
        case .Succeeded:
            createOfflinePage()
        case .Failed:
            showAlert(self.connectionError)
        case .Attempting:
            hud.show(true)
            waitingForOfflineAttributes = true
        case .Unattempted:
            showAlert(self.otherError)
        }
    }
    
    func createOfflinePage() {
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: NSNumber(integer: self.pageId)) {
            savedPage.html = attributeManager.html
            savedPage.offline = true
        } else {
            let newPage = SavedPage.MR_createEntity()
            newPage.title = pageTitle
            newPage.id = pageId
            newPage.html = attributeManager.html
            newPage.favorite = false
            newPage.offline = true
            newPage.thumbnailURL = attributeManager.thumbnailURL
        }
        save(offlineSuccess)
    }
    
    func receivedOfflineAttributes() {
        if waitingForOfflineAttributes {
            if !waitingForCoordinate && !waitingForFavoriteAttributes {
                hud.hide(true)
            }
            
            switch attributeManager.offlineState {
            case .Succeeded:
                createOfflinePage()
            case .Failed:
                showAlert(self.connectionError)
            case .Attempting:
                showAlert(self.otherError)
            case .Unattempted:
                showAlert(self.otherError)
            }
            
            waitingForOfflineAttributes = false
        }
    }
    
    // MARK: - Save

    func save(alert: String) {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({(success : Bool, error : NSError!) in
            if error != nil {
                NSLog("Error: \(error)")
            }
            
            if success {
                self.delegate?.locationWebViewControllerDidUpdatePages(self)
                self.showAlert(alert)
            } else {
                self.showAlert(self.saveError)
            }
            
            self.updateButtons()
        })
    }
    
    // MARK: - Appearance
    
    func updateButtons() {
        if let savedPage = SavedPage.MR_findFirstByAttribute("id", withValue: NSNumber(integer: self.pageId)) {
            favoriteButton.image = (savedPage.favorite == true) ? Images.starToolbarSelectedImage : Images.starToolbarImage
            downloadButton.image = (savedPage.offline == true) ? Images.downloadToolbarSelectedImage : Images.downloadToolbarImage
        } else {
            favoriteButton.image = Images.starToolbarImage
            downloadButton.image = Images.downloadToolbarImage
        }
    }
    
    func showAlert(text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.userInteractionEnabled = false
        hud.labelText = text
        hud.mode = .Text
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 1)
    }
}
