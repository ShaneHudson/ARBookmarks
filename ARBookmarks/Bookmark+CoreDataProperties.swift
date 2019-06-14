//
//  Bookmark+CoreDataProperties.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 22/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//
//

import Foundation
import CoreData


extension Bookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var title: String?
    @NSManaged public var url: URL?
    @NSManaged public var isPlaced: Bool
}
