//
//  Section.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/8/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import SwiftyJSON

class Section {
    var title: String
    var index: Int
    var json: JSON?
    var text: String?
    
    init(title: String, index: Int) {
        self.title = title
        self.index = index
    }
}
