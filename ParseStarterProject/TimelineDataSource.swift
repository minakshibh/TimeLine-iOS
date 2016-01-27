//
//  TimelineDataSource.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import CoreData

let DataSourceModelURL = NSBundle.mainBundle().URLForResource("Timeline", withExtension: "momd")!

protocol TimelineDataSource {
    
    init()
    
    func saveContext()
    
    var managedObjectContext: NSManagedObjectContext { get }
    
}
