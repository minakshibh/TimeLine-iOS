//
//  TimelineViewRight.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import Foundation

enum TimelineViewingRight {
    case BlockedTimeline(String, String)
    case BlockedUser(String, String)
    case NotPublic(String)
    case Viewable

    init(timeline: Timeline?) {
        if let timeline = timeline,
            let owner = timeline.parent,
            let user = Storage.session.currentUser
        {
            if user.uuid == owner.uuid {
                self = .Viewable
            } else if owner.blocked {
                self = .BlockedUser(owner.name ?? "", timeline.name)
            } else if timeline.blocked {
                self = .BlockedTimeline(owner.name ?? "", timeline.name)
            } else if !(owner.timelinesPublic ?? true) && owner.followed != FollowState.Following {
                self = .NotPublic(owner.name ?? "")
            } else {
                self = .Viewable
            }
        } else {
            self = .NotPublic("")
        }
    }

    static func viewableMoments(timeline: Timeline?) -> [Moment] {
        let viewingRights = TimelineViewingRight(timeline: timeline)

        if case .Viewable = viewingRights {
            return timeline?.moments ?? []
        } else {
            return []
        }
    }
}
