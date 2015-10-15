//
//  AttributeManager.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/13/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MapKit

protocol AttributeManagerDelegate: class {
    func attributeManagerReceivedCoordinate(attributeManager: AttributeManager)
    func attributeManagerReceivedFavoriteAttributes(attributeManager: AttributeManager)
    func attributeManagerReceivedOfflineAttributes(attributeManager: AttributeManager)
}

class AttributeManager {
    
    var pageId: Int
    weak var delegate: AttributeManagerDelegate?
    
    var coordinate: CLLocationCoordinate2D?
    var thumbnailURL: String?
    var html: String?
    
    private(set) var coordinateState = AttributeState.Unattempted {
        didSet { notifyCoordinateState() }
    }
    
    private var thumbnailURLState = AttributeState.Unattempted {
        didSet {
            notifyFavoriteState()
            notifyOfflineState()
        }
    }
    
    private var htmlState = AttributeState.Unattempted {
        didSet { notifyOfflineState() }
    }
    
    // Public states
    
    var favoriteState: AttributeState {
        get { return thumbnailURLState }
    }
    
    var offlineState: AttributeState {
        get {
            switch (thumbnailURLState, htmlState) {
            case (.Succeeded, .Succeeded):
                return .Succeeded
            case (.Failed, _):
                return .Failed
            case (_, .Failed):
                return .Failed
            case (.Attempting, _):
                return .Attempting
            case (_, .Attempting):
                return .Attempting
            case (_, _):
                return .Unattempted
            }
        }
    }
    
    init(pageId: Int) {
        self.pageId = pageId
    }
    
    func requestCoordinate() {
        coordinateState = .Attempting
        requestCoordinateNumberOfTimes(5)
    }
    
    func requestThumbnailURL() {
        thumbnailURLState = .Attempting
        requestThumbnailURLNumberOfTimes(5)
    }
    
    func requestHtml() {
        htmlState = .Attempting
        requestHtmlNumberOfTimes(5)
    }
    
    private func requestCoordinateNumberOfTimes(times: Int) {
        if times <= 0 {
            // Stops trying
            NSLog("Error: Couldn't get coordinates")
            coordinateState = .Failed
        } else {
            let parameters: [String: AnyObject] = [
                "action": "query",
                "format": "json",
                "pageids": pageId,
                "prop": "coordinates",
                "colimit": 1
            ]
            
            Alamofire.request(.GET, API.baseURL, parameters: parameters).responseJSON() {
                (_, _, data, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
                    self.requestCoordinateNumberOfTimes(times - 1)
                } else {
                    let json = JSON(data!)
                    let coordinates = json["query"]["pages"][String(self.pageId)]["coordinates"][0]
                    let lat = coordinates["lat"].double
                    let lon = coordinates["lon"].double
                    if let latitude = lat, longitude = lon {
                        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                    self.coordinateState = .Succeeded
                }
            }
        }
    }
    
    private func requestThumbnailURLNumberOfTimes(times: Int) {
        if times <= 0 {
            // Stops trying
            NSLog("Error: Couldn't get thumbnail")
            thumbnailURLState = .Failed
        } else {
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
                    self.requestThumbnailURLNumberOfTimes(times - 1)
                } else {
                    let json = JSON(data!)
                    let page = json["query"]["pages"][String(self.pageId)]
                    self.thumbnailURL = page["thumbnail"]["source"].string
                    self.thumbnailURLState = .Succeeded
                }
            }
        }
    }
    
    private func requestHtmlNumberOfTimes(times: Int) {
        if times <= 0 {
            // Stops trying
            NSLog("Error: Couldn't get html")
            htmlState = .Failed
        } else {
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
                    self.requestHtmlNumberOfTimes(times - 1)
                } else {
                    let json = JSON(data!)
                    self.html = json["parse"]["text"]["*"].string
                    self.htmlState = .Succeeded
                }
            }
        }
    }
    
    private func notifyCoordinateState() {
        switch coordinateState {
        case .Succeeded:
            delegate?.attributeManagerReceivedCoordinate(self)
        case .Failed:
            delegate?.attributeManagerReceivedCoordinate(self)
        default:
            break
        }
    }
    
    private func notifyFavoriteState() {
        switch favoriteState {
        case .Succeeded:
            delegate?.attributeManagerReceivedFavoriteAttributes(self)
        case .Failed:
            delegate?.attributeManagerReceivedFavoriteAttributes(self)
        default:
            break
        }
    }
    
    private func notifyOfflineState() {
        switch offlineState {
        case .Succeeded:
            delegate?.attributeManagerReceivedOfflineAttributes(self)
        case .Failed:
            delegate?.attributeManagerReceivedOfflineAttributes(self)
        default:
            break
        }
    }
}
