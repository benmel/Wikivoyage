//
//  Redirect.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/14/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

class Redirect {
    var index: Int
    var from: String
    var to: String
    
    init(index: Int, from: String, to: String) {
        self.index = index
        self.from = from
        self.to = to
    }
}
