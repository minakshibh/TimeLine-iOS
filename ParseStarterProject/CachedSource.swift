//
//  CachedSource.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import CoreData

class CachedSource: CoreDataSource, TimelineDataSource {
    
    required init() {
        super.init(modelURL: DataSourceModelURL, storeURL: CoreDataSource.cachesDirectory.URLByAppendingPathComponent("Timeline.sqlite"))
    }
    
}
