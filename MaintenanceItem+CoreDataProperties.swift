//
//  MaintenanceItem+CoreDataProperties.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/27/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//
//

import Foundation
import CoreData


extension MaintenanceItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaintenanceItem> {
        return NSFetchRequest<MaintenanceItem>(entityName: "MaintenanceItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var desc: String?
    @NSManaged public var mileage: Int64
    @NSManaged public var title: String?
    @NSManaged public var performedOn: Vehicle?

}

extension MaintenanceItem : Identifiable {

}
