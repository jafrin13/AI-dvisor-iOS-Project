//
//  UserJournal+CoreDataProperties.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/17/25.
//
//

import Foundation
import CoreData
import UIKit


extension UserJournal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserJournal> {
        return NSFetchRequest<UserJournal>(entityName: "UserJournal")
    }

    @NSManaged public var bgColor: UIColor?
    @NSManaged public var importance: String?
    @NSManaged public var title: String?
    @NSManaged public var users: User?

}

extension UserJournal : Identifiable {

}
