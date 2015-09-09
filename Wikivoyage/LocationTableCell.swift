//
//  LocationTableCell.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/8/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class LocationTableCell: UITableViewCell {
    var webView: WKWebView!
    
    override func prepareForReuse() {
        webView?.removeFromSuperview()
        webView = nil
        super.prepareForReuse()
    }
}
