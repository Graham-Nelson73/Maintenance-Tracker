//
//  Maintenance_Item+CoreDataProperties.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/20/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//
//

import Foundation
import CoreData


extension Maintenance_Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Maintenance_Item> {
        return NSFetchRequest<Maintenance_Item>(entityName: "Maintenance_Item")
    }

    @NSManaged public var date: Date?
    @NSManaged public var desc: String?
    @NSManaged public var mileage: Int64
    @NSManaged public var title: String?
    @NSManaged public var perfomred_On: Vehicle?

}
