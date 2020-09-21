//
//  Vehicle+CoreDataProperties.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/20/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var type: String?
    @NSManaged public var year: Int64
    @NSManaged public var imagePath: String?
    @NSManaged public var executes: NSSet?

}

// MARK: Generated accessors for executes
extension Vehicle {

    @objc(addExecutesObject:)
    @NSManaged public func addToExecutes(_ value: Maintenance_Item)

    @objc(removeExecutesObject:)
    @NSManaged public func removeFromExecutes(_ value: Maintenance_Item)

    @objc(addExecutes:)
    @NSManaged public func addToExecutes(_ values: NSSet)

    @objc(removeExecutes:)
    @NSManaged public func removeFromExecutes(_ values: NSSet)

}
