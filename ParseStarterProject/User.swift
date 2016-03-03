//
//  User.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

class User: Synchronized {
    var state: SynchronizationState
    typealias ParentType = Session
    
    var name: String = ""
    var email: String?
    var timelines: [Timeline] {
        didSet {
            for t in timelines ?? [] {
                t.parent = self
            }
        }
    }
    var timelinesPublic: Bool?
    var approveFollowers: Bool?
    var followersCount: Int = 0
    var followingCount: Int?
    var likesCount: Int = 0
    var pendingFollowersCount: Int?
    var liked: Bool
    var blocked: Bool
    var followed: FollowState
    var hasNews: Bool
    var externalID: String?
    var userfullName: String = ""
    weak var parent: ParentType?
    
    required init(name: String?, email: String?, externalID: String?, timelinesPublic: Bool?, approveFollowers: Bool?, pendingFollowersCount: Int?, followersCount: Int?, followingCount: Int?, likersCount: Int?, liked: Bool, blocked: Bool, followed: FollowState, hasNews: Bool = false, timelines: [Timeline], state: SynchronizationState, userfullname: String? , parent: ParentType? = nil) {
        self.name = name ?? ""
        self.email = email
        self.timelinesPublic = timelinesPublic
        self.approveFollowers = approveFollowers
        self.followersCount = followersCount ?? 0
        self.pendingFollowersCount = pendingFollowersCount
        self.parent = parent
        self.state = state
        self.followingCount = followingCount
        self.likesCount = likersCount ?? 0
        self.liked = liked
        self.blocked = blocked
        self.followed = followed
        self.externalID = externalID
        self.timelines = timelines
        self.hasNews = hasNews
        self.userfullName = userfullname ?? ""
        
        for t in timelines ?? [] {
            t.parent = self
        }
    }
    
    convenience required init(dict: [String: AnyObject], parent: Session? = nil) {
        self.init(name: dict["name"] as? String,
            email: dict["email"] as? String,
            externalID: dict["external_id"] as? String,
            timelinesPublic: dict["timelines_public"] as? Bool,
            approveFollowers: dict["approve_followers"] as? Bool,
            pendingFollowersCount: dict["pending_followers"] as? Int,
            followersCount: (dict["followers_count"] as? Int) ?? 0,
            followingCount: (dict["followees_users_count"] as? Int) ?? 0,
            likersCount: (dict["likers_count"] as? Int) ?? 0,
            liked: dict["liked"] as? Bool ?? false,
            blocked: dict["blocked"] as? Bool ?? false,
            followed: FollowState(rawValue: dict["followed"] as? String ?? "not following") ?? .NotFollowing,
            hasNews: dict["hasNews"] as? Bool ?? false,
            timelines: (dict["timelines"] as? [[String: AnyObject]] ?? []).map { Timeline(dict: $0) },
            state: SynchronizationState(dict: dict["state"] as? [String: AnyObject] ?? dict),
            userfullname : dict["userfullname"]  as? String ,
            parent: parent
        )
    }
    
}

extension User: DictConvertable {
    
    var dict: [String: AnyObject] {
        let state = self.state.dict
        let timelines = (self.timelines ?? []).map { $0.dict }
        let optionalPairs: [(String, AnyObject?)] = [("state", state), ("name", name), ("email", email), ("timelines", timelines), ("timelines_public", timelinesPublic), ("followers_count", followersCount), ("approve_followers", approveFollowers), ("liked", liked), ("followed", followed.rawValue), ("external_id", externalID), ("pending_followers", pendingFollowersCount), ("blocked", blocked), ("followees_users_count", followingCount), ("likers_count", likesCount), ("hasNews", hasNews) , ("userfullname", userfullName)]
        var result = [String: AnyObject]()
        for (k,ov) in optionalPairs {
            if let v: AnyObject = ov {
                result[k] = v
            }
        }
        return result
    }
}

extension User {
    var uuid: UUID? {
        switch state {
        case .LocalOnly:
            return nil
        case .Synced(let uuid, _, _):
            return uuid
        case .Dummy(let uuid):
            return uuid
        }
    }
    
    func reloadUser(completion: Void -> Void) {
        if let uuid = self.state.uuid {
            Storage.performRequest(ApiRequest.UserProfile(uuid), completion: { (json) -> Void in
                let new = User(dict: json, parent: nil)
                self.state = new.state
                self.followed = new.followed
                self.timelinesPublic = new.timelinesPublic
                self.approveFollowers = new.approveFollowers
                self.followersCount = new.followersCount
                self.followingCount = new.followingCount
                self.likesCount = new.likesCount
                self.liked = new.liked
                self.blocked = new.blocked
                self.userfullName = new.userfullName
                Storage.save()
                completion()
            })
        }
    }
    
    func reloadTimelines(completion: Void -> Void) {
        Storage.performRequest(ApiRequest.TimelineUser(state.uuid!), completion: { (json) -> Void in
            var old = Set(self.timelines.map { $0.state.uuid ?? "" })
            var dirty = false
            if let timelines = json["result"] as? [[String: AnyObject]] {
                for t in timelines {
                    let uuid = t["id"] as? UUID ?? ""
                    old.remove(uuid)
                    if let time = Storage.findTimeline(uuid) {
                        // refresh
                        time.reloadMoments { }
                    } else {
                        // create timeline
                        let time = Timeline(dict: t, parent: nil)
                        self.timelines.append(time)
                        dirty = true
                    }
                }
            }
            self.timelines = self.timelines.filter {
                !old.contains($0.state.uuid ?? "")
            }
            if dirty {
                Storage.save()
            }
            completion()
        })
    }
    
    func like(completion: () -> ()) {
        self.likesCount = (self.likesCount ?? 0) + 1
        let new = self.likesCount
        self.liked = true
        
        Storage.performRequest(ApiRequest.UserLike(state.uuid!), completion: { (json) -> Void in
            if let likes = json["likes"] as? Int {
                self.likesCount = likes
                self.liked = true
            } else {
                self.liked = false
                if self.likesCount == new {
                    self.likesCount = new - 1
                }
            }
            
            Storage.save()
            completion()
        })
    }
    
    func unlike(completion: () -> ()) {
        self.likesCount = (self.likesCount ?? 1) - 1
        let new = self.likesCount
        self.liked = false
        
        Storage.performRequest(ApiRequest.UserUnlike(state.uuid!), completion: { (json) -> Void in
            if let likes = json["likes"] as? Int {
                self.likesCount = likes
                self.liked = false
            } else {
                self.liked = true
                if self.likesCount == new {
                    self.likesCount = new + 1
                }
            }
            
            Storage.save()
            completion()
        })
    }
    
    func follow(completion: () -> ()) {
        self.followersCount = (self.followersCount ?? 0) + 1
        let new = self.followersCount
        let oldState = self.followed
        self.followed = .Pending
        
        Storage.performRequest(ApiRequest.UserFollow(state.uuid!), completion: { (json) -> Void in
            if let followers = json["followers"] as? Int {
                self.followersCount = followers
            }
            if let state = json["state"] as? String {
                switch state {
                case "success":
                    self.followed = .Following
                case "following":
                    self.followed = .Following
                case "pending":
                    self.followed = .Pending
                default:
                    self.followed = oldState
                }
            } else {
                if self.followersCount == new {
                    self.followersCount = new - 1
                }
            }
            
            Storage.save()
            completion()
        })
    }
    
    func unfollow(completion: () -> ()) {
        self.followersCount = (self.followersCount ?? 1) - 1
        let new = self.followersCount
        let oldState = self.followed
        self.followed = .NotFollowing
        
        Storage.performRequest(ApiRequest.UserUnfollow(state.uuid!), completion: { (json) -> Void in
            if let followers = json["followers"] as? Int {
                self.followersCount = followers
            } else {
                if self.followersCount == new {
                    self.followersCount = new - 1
                }
            }
            if let state = json["state"] as? String {
                switch state {
                case "success":
                    self.followed = .NotFollowing
                case "following":
                    self.followed = .Following
                case "pending":
                    self.followed = .Following
                default:
                    self.followed = oldState
                }
            } else {
                self.followed = oldState
            }
            
            Storage.save()
            completion()
        })
    }
    
    func approve(completion: () -> ()) {
        self.followed = .Following
        Storage.performRequest(ApiRequest.UserApprove(state.uuid!), completion: { (json) -> Void in
            if let state = json["state"] as? String {
                switch state {
                case "success", "approved", "already_approved":
                    self.followed = .Following
                default:
                    self.followed = .Pending
                }
            }
            Storage.save()
            completion()
        })
    }
    
    func decline(completion: () -> ()) {
        self.followed = .NotFollowing
        Storage.performRequest(ApiRequest.UserDecline(state.uuid!), completion: { (json) -> Void in
            if let state = json["state"] as? String {
                switch state {
                case "success", "declined", "already_declined", "not_pending", "not_following":
                    self.followed = .NotFollowing
                default:
                    self.followed = .Pending
                }
            }
            Storage.save()
            completion()
        })
    }
    
    func block(completion: () -> ()) {
        self.blocked = true
        Storage.performRequest(ApiRequest.UserBlock(state.uuid!), completion: { (json) -> Void in
            if let state = json["state"] as? String {
                switch state {
                case "success", "already blocked", "already_blocked", "blocked", "not blocked":
                    self.blocked = true
                default:
                    self.blocked = false
                }
            }
            Storage.save()
            completion()
        })
    }
    
    func unblock(completion: () -> ()) {
        self.blocked = false
        Storage.performRequest(ApiRequest.UserUnblock(state.uuid!), completion: { (json) -> Void in
            if let state = json["state"] as? String {
                switch state {
                case "success", "already_unblocked", "not_blocked", "not blocked":
                    self.blocked = false
                default:
                    self.blocked = true
                }
            }
            Storage.save()
            completion()
        })
    }
}

extension User {
    
    static func getUsers(request: ApiRequest, completion: ([User]) -> Void) {
        let cached: [User]
        switch request {
        case .CurrentUserBlocked:
            cached = Storage.session.currentUserBlockedCache.map(Storage.findUser).filter { $0 != nil }.map { $0! }
            
        case .CurrentUserFollowing:
            cached = Storage.session.currentUserFollowingCache.map(Storage.findUser).filter { $0 != nil }.map { $0! }
            
        case .CurrentUserPending:
            cached = Storage.session.currentUserPendingCache.map(Storage.findUser).filter { $0 != nil }.map { $0! }
            
        case .CurrentTimelineFollowers:
            cached = Storage.session.currentTimelineFollowersCache.map(Storage.findUser).filter { $0 != nil }.map { $0! }
            
        case .CurrentUserFollowers:
            cached = Storage.session.currentUserFollowersCache.map(Storage.findUser).filter { $0 != nil }.map { $0! }
            
        default:
            cached = []
        }
        completion(cached)
        
        Storage.performRequest(request, completion: { (json) -> Void in
            if let results = json["result"] as? [[String: AnyObject]] {
                var users = results.map { User(dict: $0, parent: nil) }
                for i in 0..<users.count {
                    let u = users[i]
                    if let existing = Storage.findUser(u.state.uuid!) {
                        existing.state = u.state
                        existing.name = u.name
                        existing.email = u.email
                        existing.timelinesPublic = u.timelinesPublic
                        existing.approveFollowers = u.approveFollowers
                        existing.followersCount = u.followersCount
                        existing.followingCount = u.followingCount
                        existing.likesCount = u.likesCount
                        existing.pendingFollowersCount = u.pendingFollowersCount
                        existing.liked = u.liked
                        existing.blocked = u.blocked
                        existing.followed = u.followed
                        existing.userfullName = u.userfullName

                        users[i] = existing
                    } else {
                        Storage.session.users.append(u)
                    }
                }
                
                switch request {
                case .CurrentUserBlocked:
                    Storage.session.currentUserBlockedCache = users.map { $0.state.uuid! }
                    
                case .CurrentUserFollowing:
                    Storage.session.currentUserFollowingCache = users.map { $0.state.uuid! }
                    
                case .CurrentUserPending:
                    Storage.session.currentUserPendingCache = users.map { $0.state.uuid! }
                    
                case .CurrentTimelineFollowers:
                    Storage.session.currentTimelineFollowersCache = users.map { $0.state.uuid! }
                    
                case .CurrentUserFollowers:
                    Storage.session.currentUserFollowersCache = users.map { $0.state.uuid! }
                    
                default:
                    break
                }
                
                Storage.save()
                
                Storage.save()
                completion(users)
            }
            else {
                completion(cached)
            }
        })
    }
    
}
