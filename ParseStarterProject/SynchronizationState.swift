//
//  SynchronizationState.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

/// oldest first
func <<T: Synchronized>(lhs: T, rhs: T) -> Bool {
    switch (lhs.state, rhs.state) {
    case (.LocalOnly, _):
        return false
    case (.Dummy(_), .LocalOnly):
        return true
    case (.Dummy(_), _):
        return false
    case (.Synced(_, _, let lu), .Synced(_, _, let ru)):
        return lu < ru
    default:
        return false
    }
}
func ==<T: Synchronized>(lhs: T, rhs: T) -> Bool {
    switch (lhs.state, rhs.state) {
    case (.LocalOnly, .LocalOnly):
        return true
    case let (.Dummy(l), .Dummy(r)):
        return l == r
    case (.Synced(let lid, _, let lup), .Synced(let rid, _, let rup)):
        return lup < rup && lid == rid
    default:
        return false
    }
}
func ><T: Synchronized>(lhs: T, rhs: T) -> Bool {
    return rhs < lhs
}


enum SynchronizationState: DictConvertable {
    case LocalOnly
    case Dummy(UUID)
    case Synced(UUID, NSDate, NSDate)
    
    static var formatter: NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        f.timeZone = NSTimeZone(name: "UTC")
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        return f
    }
    
    typealias ParentType = ()
    
    init(dict: [String: AnyObject], parent: ParentType? = nil) {
        if let cr = dict["created_at"] as? String,
            let up = dict["updated_at"] as? String,
            let dcr = SynchronizationState.formatter.dateFromString(cr),
            let dup = SynchronizationState.formatter.dateFromString(up),
            let uuid = dict["uuid"] as? String ?? dict["id"] as? String
        {
            self = .Synced(uuid, dcr, dup)
        } else if let uuid = dict["uuid"] as? String ?? dict["id"] as? String {
            self = .Dummy(uuid)
        } else {
            self = .LocalOnly
        }
    }
    
    var parent: ParentType? {
        return nil
    }
    var dict: [String: AnyObject] {
        switch self {
        case let .Synced(uuid, dcr, dup):
            return ["created_at": SynchronizationState.formatter.stringFromDate(dcr), "updated_at": SynchronizationState.formatter.stringFromDate(dup), "uuid": uuid]
        case .LocalOnly:
            return [:]
        case .Dummy(let uuid):
            return ["uuid": uuid]
        }
    }
    
    var uuid: UUID? {
        switch self {
        case .LocalOnly:
            return nil
        case .Synced(let uuid, _, _):
            return uuid
        case .Dummy(let uuid):
            return uuid
        }
    }
    
    var createdAt: NSDate? {
        switch self {
        case .Synced(_, let c, _):
            return c
        
        case .LocalOnly, .Dummy(_):
            return nil
        }
    }
    
    var updatedAt: NSDate? {
        switch self {
        case .LocalOnly, .Dummy(_):
            return nil
            
        case .Synced(_, _, let c):
            return c
        }
    }
}
