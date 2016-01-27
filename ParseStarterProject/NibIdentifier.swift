//
//  NibIdentifier.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

extension NSBundle {
    
    enum NibIdentifier: String {
        case TimelineTableHeaderView = "TimelineTableHeaderView"
        case DraftPreview = "DraftPreview"
    }
    
    func loadNib(identifier: NibIdentifier, owner: AnyObject!) -> [AnyObject]! {
        return self.loadNibNamed(identifier.rawValue, owner: owner, options: [:])
    }
    
}