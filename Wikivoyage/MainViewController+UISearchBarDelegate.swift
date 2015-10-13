//
//  MainViewController+UISearchBarDelegate.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/6/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        mainView.dismissKeyboard()
        if !searchBar.text.isEmpty {
            queryTitles(searchBar.text)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchResults.removeAll(keepCapacity: false)
        mainView.resetSearchBar(true)
    }
    
    // If the search text stays the same for 0.3 seconds then search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let delay = 0.3
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue()) {
                if searchText == searchBar.text {
                    self.queryTitles(searchText)
                }
            }
        }
    }
    
    func queryTitles(searchTerm: String) {
        // Update lastRequestid
        lastRequestid = searchTerm
        
        let limit = 20
        
        let parameters: [String: AnyObject] = [
            "action": "query",
            "format": "json",
            "requestid": searchTerm,
            "generator": "prefixsearch",
            "gpssearch": searchTerm,
            "gpslimit": limit,
            "prop": "pageimages",
            "piprop": "thumbnail",
            "pithumbsize": Images.thumbnailSize,
            "pilimit": limit
        ]
        
        Alamofire.request(.GET, API.baseURL, parameters: parameters).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let requestid = json["requestid"].stringValue
                // Only update results using latest request
                if requestid == self.lastRequestid {
                    self.searchResults.removeAll(keepCapacity: false)
                    let results = json["query"]["pages"]
                    
                    for (index: String, subJson: JSON) in results {
                        if let index = subJson["index"].int, pageid = subJson["pageid"].int, title = subJson["title"].string {
                            let thumbnail = subJson["thumbnail"]["source"].string
                            let searchResult = SearchResult(index: index, pageId: pageid, pageTitle: title, thumbnailURL: thumbnail)
                            self.searchResults.append(searchResult)
                        }
                    }
                    
                    self.searchResults.sort { $0.index < $1.index }
                    self.mainView.reloadTableRows()
                }
            }
        }
    }
}
