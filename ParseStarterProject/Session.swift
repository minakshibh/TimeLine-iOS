//
//  Session.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import Parse

class Session: DictConvertable {
    
    var notificationDate: NSDate?
    
    var allowedTimelinesCount: Int?
    var unsyncedTimelineIncrement: Int = 0
    var activeTimelineIncrementSyncs: Int
    var webToken: String?
    var sessionToken: String?
    var uuid: UUID?
    var users: [User]
    var drafts: [Moment]
    
    var trendingCache: [UUID]
    var followingCache: [UUID]
    var currentTimelineFollowingCache: [UUID]
    var currentTimelineBlockedCache: [UUID]
    
    var currentUserBlockedCache: [UUID]
    var currentUserFollowingCache: [UUID]
    var currentUserPendingCache: [UUID]
    var currentTimelineFollowersCache: [UUID]
    var currentUserFollowersCache: [UUID]
    
    
    var walkedThroughCamera: Bool
    var walkedThroughMine: Bool
    var walkedThroughTrends: Bool
    var walkedThroughMoments: Bool
    var walkedThroughApprove: Bool
    
    typealias ParentType = ()
    required init(uuid: UUID?, webToken: String?, sessionToken: String?, allowedTimelinesCount: Int?, unsyncedTimelineIncrement: Int = 0, users: [User], drafts: [Moment] = [], trendingCache: [UUID] = [], followingCache: [UUID] = [], currentTimelineFollowingCache: [UUID] = [], currentTimelineBlockedCache: [UUID] = [], currentUserBlockedCache: [UUID] = [], currentUserFollowingCache: [UUID] = [], currentUserPendingCache: [UUID] = [], currentTimelineFollowersCache: [UUID] = [], currentUserFollowersCache: [UUID] = [], walkedThroughCamera: Bool = false, walkedThroughMine: Bool = false, walkedThroughTrends: Bool = false, walkedThroughMoments: Bool = false, walkedThroughApprove: Bool = false, notificationDate: NSDate? = nil) {
        self.uuid = uuid
        self.webToken = webToken
        self.sessionToken = sessionToken
        self.users = users
        self.drafts = drafts
        self.allowedTimelinesCount = allowedTimelinesCount
        self.trendingCache = trendingCache
        self.followingCache = followingCache
        self.unsyncedTimelineIncrement = unsyncedTimelineIncrement
        self.activeTimelineIncrementSyncs = unsyncedTimelineIncrement
        
        self.currentTimelineBlockedCache = currentTimelineBlockedCache
        self.currentTimelineFollowingCache = currentTimelineFollowingCache
        
        self.currentUserBlockedCache = currentUserBlockedCache
        self.currentUserFollowingCache = currentUserFollowingCache
        self.currentUserPendingCache = currentUserPendingCache
        self.currentTimelineFollowersCache = currentTimelineFollowersCache
        self.currentUserFollowersCache = currentUserFollowersCache
        
        self.walkedThroughCamera = walkedThroughCamera
        self.walkedThroughMine = walkedThroughMine
        self.walkedThroughMoments = walkedThroughMoments
        self.walkedThroughTrends = walkedThroughTrends
        self.walkedThroughApprove = walkedThroughApprove
        
        self.notificationDate = notificationDate
        
        for u in users {
            u.parent = self
        }
    }
    convenience required init(dict: [String : AnyObject], parent: ParentType? = nil) {
        self.init(uuid: dict["uuid"] as? UUID,
            webToken: dict["web_token"] as? String,
            sessionToken: dict["session_token"] as? String,
            allowedTimelinesCount: dict["allowed_timelines_count"] as? Int,
            unsyncedTimelineIncrement: dict["unsyncedTimelineIncrement"] as? Int ?? 0,
            users: (dict["users"] as? [[String: AnyObject]] ?? []).map { User(dict: $0, parent: nil) },
            drafts: (dict["drafts"] as? [[String: AnyObject]] ?? []).map { Moment(dict: $0, parent: nil) },
            trendingCache: dict["trending_cache"] as? [UUID] ?? [],
            followingCache: dict["following_cache"] as? [UUID] ?? [],
            currentTimelineFollowingCache: dict["currentTimelineFollowingCache"] as? [UUID] ?? [],
            currentTimelineBlockedCache: dict["currentTimelineBlockedCache"] as? [UUID] ?? [],
            
            
            currentUserBlockedCache: dict["currentUserBlockedCache"] as? [UUID] ?? [],
            currentUserFollowingCache: dict["currentUserFollowingCache"] as? [UUID] ?? [],
            currentUserPendingCache: dict["currentUserPendingCache"] as? [UUID] ?? [],
            currentTimelineFollowersCache: dict["currentTimelineFollowersCache"] as? [UUID] ?? [],
            currentUserFollowersCache: dict["currentUserFollowersCache"] as? [UUID] ?? [],
            
            walkedThroughCamera: dict["walked_through_camera"] as? Bool ?? false,
            walkedThroughMine: dict["walked_through_mine"] as? Bool ?? false,
            walkedThroughTrends: dict["walked_through_trends"] as? Bool ?? false,
            walkedThroughMoments: dict["walked_through_moments"] as? Bool ?? false,
            walkedThroughApprove: dict["walked_through_approve"] as? Bool ?? false,
            
            notificationDate: SynchronizationState.formatter.dateFromString(dict["notificationDate"] as? String ?? "")
        )
    }
    
    var parent: ParentType?
    var dict: [String: AnyObject] {
        let userDicts: [[String: AnyObject]] = users.map { $0.dict }
        let draftDicts: [[String: AnyObject]] = drafts.map { $0.dict }
        var dict: [String: AnyObject] = ["users": userDicts, "drafts": draftDicts, "trending_cache": trendingCache, "following_cache": followingCache, "unsyncedTimelineIncrement": unsyncedTimelineIncrement, "walked_through_camera": walkedThroughCamera, "walked_through_mine": walkedThroughMine, "walked_through_trends": walkedThroughTrends, "walked_through_moments": walkedThroughMoments, "walked_through_approve": walkedThroughApprove, "currentTimelineFollowingCache": currentTimelineFollowingCache, "currentTimelineBlockedCache": currentTimelineBlockedCache, "currentUserBlockedCache": currentUserBlockedCache, "currentUserFollowingCache": currentUserFollowingCache, "currentUserPendingCache": currentUserPendingCache, "currentTimelineFollowersCache": currentTimelineFollowersCache, "currentUserFollowersCache": currentUserFollowersCache]
        if let webToken = webToken, let uuid = uuid, let sessionToken = sessionToken {
            dict["web_token"] = webToken
            dict["session_token"] = sessionToken
            dict["uuid"] = uuid
        }
        if let allowedTimelinesCount = allowedTimelinesCount {
            dict["allowed_timelines_count"] = allowedTimelinesCount
        }
        if let notificationDate = notificationDate {
            dict["notificationDate"] = SynchronizationState.formatter.stringFromDate(notificationDate)
        }
        return dict
    }

}

extension Session {
    
    enum AuthLevel: Int {
        case None = 0
        case Partial
        case Full
    }
    var authLevel: AuthLevel {
        if let _ = PFUser.currentUser() {
            if let _ = webToken {
                return .Full
            }
            return .Partial
        }
        return .None
    }
    
    convenience init() {
        self.init(dict: [:])
    }
    
    
}

extension Session {
    
    var currentUser: User? {
        return users.filter { $0.uuid == self.uuid }.first
    }
    
}

