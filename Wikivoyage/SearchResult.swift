//
//  SearchResult.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/31/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

class SearchResult {
    var pageId: Int
    var pageTitle: String
    
    init(pageId: Int, pageTitle: String) {
        self.pageId = pageId
        self.pageTitle = pageTitle
    }
}
