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
            "pilimit": limit,
            "redirects": ""
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
                    let redirects = json["query"]["redirects"]
                    let pages = json["query"]["pages"]
                    
                    var redirectDictionary = [String: Redirect]()
                    for (idx: String, subJson: JSON) in redirects {
                        if let index = subJson["index"].int, from = subJson["from"].string, to = subJson["to"].string {
                            let redirect = Redirect(index: index, from: from, to: to)
                            redirectDictionary[redirect.to] = redirect
                        }
                    }
                    
                    var searchResultArray = [SearchResult]()
                    for (idx: String, subJson: JSON) in pages {
                        if let pageid = subJson["pageid"].int, title = subJson["title"].string {
                            let thumbnail = subJson["thumbnail"]["source"].string
                            if let index = subJson["index"].int {
                                let searchResult = SearchResult(index: index, pageId: pageid, pageTitle: title, thumbnailURL: thumbnail)
                                searchResultArray.append(searchResult)
                            } else {
                                if let redirect = redirectDictionary[title] {
                                    let searchResult = SearchResult(index: redirect.index, pageId: pageid, pageTitle: redirect.to, originalTitle: redirect.from, thumbnailURL: thumbnail)
                                    searchResultArray.append(searchResult)
                                }
                            }
                        }
                    }
                    
                    searchResultArray.sort { $0.index < $1.index }
                    self.searchResults = searchResultArray
                    self.mainView.reloadTableRows()
                }
            }
        }
    }
}
