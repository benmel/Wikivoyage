//
//  TableRow.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/8/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

class TableRow {
    var type: String
    var sectionTextVisible: Bool
    var section: Section
    
    init(type: String, sectionTextVisible: Bool, section: Section) {
        self.type = type
        self.sectionTextVisible = sectionTextVisible
        self.section = section
    }
}
