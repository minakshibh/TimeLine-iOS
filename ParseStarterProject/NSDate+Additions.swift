//
//  NSDate+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }