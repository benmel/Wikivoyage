//
//  LeakAvoider.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/21/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import WebKit

class LeakAvoider: NSObject, WKScriptMessageHandler {

    weak var delegate : WKScriptMessageHandler?
    
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
        
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceiveScriptMessage: message)
    }
}
