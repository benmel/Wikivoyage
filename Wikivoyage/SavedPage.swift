//
//  SavedPage.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/16/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Foundation
import CoreData

@objc(SavedPage)
class SavedPage: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var html: String
    @NSManaged var title: String

}
