//
//  SearchResult.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/31/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

class SearchResult {
    var index: Int
    var pageId: Int
    var pageTitle: String
    var originalTitle: String?
    var thumbnailURL: String?
    
    init(index: Int, pageId: Int, pageTitle: String, thumbnailURL: String?) {
        self.index = index
        self.pageId = pageId
        self.pageTitle = pageTitle
        self.thumbnailURL = thumbnailURL
    }
    
    convenience init(index: Int, pageId: Int, pageTitle: String, originalTitle: String?, thumbnailURL: String?) {
        self.init(index: index, pageId: pageId, pageTitle: pageTitle, thumbnailURL: thumbnailURL)
        self.originalTitle = originalTitle
    }
}
