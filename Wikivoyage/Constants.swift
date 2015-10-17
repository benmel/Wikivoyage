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
    static let placeholder = "placeholder"
    static let thumbnailSize = 128
    static let backgroundImage = UIImage(named: "mountains")
}

struct Color {
    static let emptyButtonColor = UIColor.blueColor()
    static let fullButtonColor = UIColor.redColor()
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
