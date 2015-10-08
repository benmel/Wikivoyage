//
//  SavedPage.swift
//  Wikivoyage
//
//  Created by Ben Meline on 9/25/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import Foundation
import CoreData

class SavedPage: NSManagedObject {

    @NSManaged var html: String?
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var favorite: NSNumber
    @NSManaged var offline: NSNumber
    @NSManaged var thumbnailURL: String?

}
