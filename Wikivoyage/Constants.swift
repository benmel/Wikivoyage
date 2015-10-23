//
//  Constants.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/6/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

struct API {
    static let baseURL = "http://en.wikivoyage.org/w/api.php"
    static let siteURL = "http://en.m.wikivoyage.com/wiki/"
    static let requestTimeout: NSTimeInterval = 10
}

struct Images {
    static let thumbnailSize = 128
    static let logoImage = UIImage(named: "logo")
    static let mapLocationLargeImage = UIImage(named: "map-location-large")?.imageWithRenderingMode(.AlwaysTemplate)
    static let backgroundImage = UIImage(named: "mountains")
    static let searchImage = UIImage(named: "search")?.imageWithRenderingMode(.AlwaysTemplate)
    static let listImage = UIImage(named: "list-toolbar")
    static let starImage = UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate)
    static let starLargeImage = UIImage(named: "star-large")?.imageWithRenderingMode(.AlwaysTemplate)
    static let starToolbarImage = UIImage(named: "star-toolbar")
    static let starToolbarSelectedImage = UIImage(named: "star-toolbar-selected")
    static let downloadImage = UIImage(named: "cloud-download")?.imageWithRenderingMode(.AlwaysTemplate)
    static let downloadLargeImage = UIImage(named: "cloud-download-large")?.imageWithRenderingMode(.AlwaysTemplate)
    static let downloadToolbarImage = UIImage(named: "cloud-download-toolbar")
    static let downloadToolbarSelectedImage = UIImage(named: "cloud-download-toolbar-selected")
    static let mapImage = UIImage(named: "map-toolbar")
    static let backImage = UIImage(named: "arrow-left-toolbar")
    static let forwardImage = UIImage(named: "arrow-right-toolbar")
    static let closeImage = UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate)
}

struct System {
    static let version = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
}

enum AttributeState {
    case Unattempted
    case Attempting
    case Succeeded
    case Failed
}
