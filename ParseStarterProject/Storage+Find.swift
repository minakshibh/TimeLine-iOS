//
//  Storage+Find.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

extension Storage {
    
    static func findUser(uuid: UUID) -> User? {
        for u in session.users {
            if u.state.uuid == uuid {
                return u
            }
        }
        return nil
    }
    
    static func findTimeline(uuid: UUID) -> Timeline? {
        let timelines = session.users.reduce([]) { $0 + $1.timelines }
        for t in timelines {
            if t.state.uuid == uuid {
                return t
            }
        }
        return nil
    }
    
    static func findMoment(uuid: UUID) -> Moment? {
        let timelines = session.users.reduce([]) { $0 + $1.timelines }
        let moments = timelines.reduce([]) { $0 + $1.moments }

        for m in moments {
            if m.state.uuid == uuid {
                return m
            }
        }
        return nil
    }
    
}
