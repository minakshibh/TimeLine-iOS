//
//  PersistentSource.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import CoreData

class PersistentSource: CoreDataSource, TimelineDataSource {
   
    required init() {
        super.init(modelURL: DataSourceModelURL, storeURL: CoreDataSource.documentsDirectory.URLByAppendingPathComponent("Timeline.sqlite"))
    }
    
}
