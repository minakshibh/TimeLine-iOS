//
//  Timeline.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

enum FollowState: String {
    case Following = "following"
    case Pending = "pending"
    case NotFollowing = "not following"

    static func from(rawValue rawValue: Bool) -> FollowState {
        if rawValue {
            return.Following
        } else {
            return .NotFollowing
        }
    }
}

class Timeline: Synchronized, DictConvertable {
    var state: SynchronizationState
    
    var name: String
    var updated_at:String
    var moments: [Moment]
    var followersCount: Int
    var likesCount: Int
    var liked: Bool
    var blocked: Bool
    var followed: FollowState
    var duration: Int = 0
    var hasNews: Bool
    var persistent: Bool
    var groupTimeline: Bool
    var commentsCount: Int = 0
    var description: String
    var adminId: String

    weak var parent: ParentType?
    
    typealias ParentType = User
    required init(name: String, followersCount: Int, likesCount: Int, liked: Bool, blocked: Bool, followed: FollowState, hasNews: Bool = false, persistent: Bool = false, duration: Int?, moments: [Moment], state: SynchronizationState, grouptimeline: Bool, commentscount: Int? , description: String , adminId: String , parent: User? = nil,updated_at: String) {
        self.name = name
        self.updated_at = updated_at
        self.parent = parent
        self.state = state
        self.followersCount = followersCount
        self.likesCount = likesCount
        self.liked = liked
        self.followed = followed
        self.blocked = blocked
        self.duration = duration ?? 0
        self.hasNews = hasNews
        self.persistent = persistent
        self.groupTimeline = grouptimeline
        self.commentsCount = commentscount! ?? 0
        self.description = description
        self.adminId = adminId
        
        self.moments = moments.sort { lhs, rhs in
            switch (lhs.state, rhs.state) {
            case (.LocalOnly, _):
                return false
            case (_, .LocalOnly):
                return true
            case (.Dummy(_), _):
                return false
            case (_, .Dummy(_)):
                return true
            case (.Synced(_, let lcr, _), .Synced(_, let rcr, _)):
                return lcr < rcr
            default:
                assertionFailure("Timeline.init: moments couldn't be sorted\nlhs: \(lhs.dict)\nrhs:\(rhs.dict)")
                return false
            }
        }
        
        for m in moments {
            m.parent = self
        }
    }
    convenience required init(dict: [String: AnyObject], parent: ParentType? = nil) {
        let duration = dict["moments_duration"] as? Float
        self.init(name: (dict["name"] as? String) ?? "",
            followersCount: (dict["followers_count"] as? Int) ?? 0,
            likesCount: (dict["likes_count"] as? Int) ?? 0,
            liked: dict["liked"] as? Bool ?? false,
            blocked: dict["blocked"] as? Bool ?? false,
            followed: FollowState(rawValue: dict["followed"] as? String ?? "not following") ?? .NotFollowing,
            hasNews: dict["hasNews"] as? Bool ?? false,
            persistent: dict["persistent"] as? Bool ?? false,
            duration: duration != nil ? Int(floor(duration!)) : (dict["moments_duration"] as? Int),
            moments: (dict["moments"] as? [[String: AnyObject]] ?? []).map { Moment(dict: $0) },
            state: SynchronizationState(dict: dict["state"] as? [String: AnyObject] ?? dict),
            grouptimeline: dict["group_timeline"] as? Bool ?? false , commentscount: (dict["comments_count"] as? Int) ?? 0 ,description :(dict["description"] as? String) ?? "" , adminId : (dict["admin_id"] as? String) ?? "" , parent: parent,updated_at: (dict["updated_at"] as? String) ?? ""
        )
    }
    
    var dict: [String: AnyObject] {
        return ["state": state.dict, "name": name, "followers_count": followersCount, "likes_count": likesCount, "moments": moments.map { $0.dict }, "liked": liked, "followed": followed.rawValue, "moments_duration": duration ?? 0, "blocked": blocked, "hasNews": hasNews, "persistent": persistent , "group_timeline" : groupTimeline , "comments_count" : commentsCount ?? 0 , "description" :description ,"admin_id" : adminId]
    }
    
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
}

extension Timeline {
    
    static func getTimelines(request: ApiRequest, completion: ([Timeline]) -> Void) {
        switch request {
        case .TimelineFollowing:
            completion(Storage.session.followingCache.map(Storage.findTimeline).filter { $0 != nil }.map { $0! })
            
        case .TimelineTrending:
            completion(Storage.session.trendingCache.map(Storage.findTimeline).filter { $0 != nil }.map { $0! })
        
        case .TimelineMe:
            completion(Storage.session.currentUser?.timelines ?? [])
        
        case .CurrentTimelineFollowing:
            completion(Storage.session.currentTimelineFollowingCache.map(Storage.findTimeline).filter { $0 != nil }.map { $0! })
            
        case .CurrentTimelineBlocked:
            completion(Storage.session.currentTimelineBlockedCache.map(Storage.findTimeline).filter { $0 != nil }.map { $0! })
        
        default:
            break
        }
        
        Storage.performRequest(request) { (json) -> Void in
            var timelines = [Timeline]()
            
            let tempTimelinesArray : NSMutableArray = []
            if let timelineDicts = json["result"] as? [[String: AnyObject]] {
                
                for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                    let t = Storage.session.currentUser!.timelines[i]
                    var containtl : Bool = false
                    for td in timelineDicts
                    {
                        let tid = td["id"] as! UUID
                        if tid == t.state.uuid
                        {
                            containtl = true
                        }
                    }
                    if !containtl{
                        tempTimelinesArray.addObject(i)
                    }
                }
//                if tempTimelinesArray.count > 0
//                {
//                    for i in 0..<(tempTimelinesArray.count ?? 0) {
//                        Storage.session.currentUser!.timelines.removeAtIndex(i)
//                        serialHook.perform(key: .ForceReloadData, argument: ())
//                    }
//                }
                
                for td in timelineDicts {
                    //print(timelineDicts)
                    if let userID = td["user_id"] as? UUID
                    {
                        let owner: User
                        if let user = Storage.findUser(userID)
                        { // update user
                            owner = user
                        } else
                        { // set up user
//                            owner = User(name: nil, email: nil, externalID: nil, timelinesPublic: nil, approveFollowers: nil, pendingFollowersCount: nil, followersCount: nil, followingCount: nil, likersCount: nil, liked: false, blocked: false, followed: .NotFollowing, timelines: [], state: .Dummy(userID), parent: Storage.session)
                            
                            owner = User(name: nil, email: nil, externalID: nil, timelinesPublic: nil, approveFollowers: nil, pendingFollowersCount: nil, followersCount: nil, followingCount: nil, likersCount: nil, liked: false, blocked: false, followed: .NotFollowing, timelines: [], state: .Dummy(userID), userfullname: nil , parent: Storage.session)

                            
                            Storage.session.users.append(owner)
                            
                            Storage.performRequest(ApiRequest.UserProfile(userID), completion: { (json) -> Void in
                                if let v = json["name"] as? String {
                                    owner.name = v
                                }
                                if let v = json["email"] as? String {
                                    owner.email = v
                                }
                                if let v = json["external_id"] as? String {
                                    owner.externalID = v
                                }
                                if let v = json["timelines_public"] as? Bool {
                                    owner.timelinesPublic = v
                                }
                                if let v = json["approve_followers"] as? Bool {
                                    owner.approveFollowers = v
                                }
                                if let v = json["followers_count"] as? Int {
                                    owner.followersCount = v
                                }
                                if let v = json["followees_users_count"] as? Int {
                                    owner.followingCount = v
                                }
                                if let v = json["likers_count"] as? Int {
                                    owner.likesCount = v
                                }
                                if let v = json["updated_at"] as? String {
                                    owner.updated_at = v
                                }
                                if let v = json["liked"] as? Bool {
                                    owner.liked = v
                                }
                                if let r = json["followed"] as? String,
                                    let v = FollowState(rawValue: r)
                                {
                                    owner.followed = v
                                }
                                if let v = json["blocked"] as? Bool {
                                    owner.blocked = v
                                }
                               
                                owner.state = SynchronizationState(dict: json)
                                Storage.save()
                            })
                            owner.reloadUser { }
                        }
                        
                        let tl: Timeline
                        let tid = td["id"] as! UUID
                        if let existing = Storage.findTimeline(tid)
                        { // update timeline
                            if let fc = td["followers_count"] as? Int {
                                existing.followersCount = fc
                            }
                            if let lc = td["likers_count"] as? Int {
                                existing.likesCount = lc
                            }
                            if let lc = td["liked"] as? Bool {
                                existing.liked = lc
                            }
                            if let rc = td["followed"] as? String,
                                let lc = FollowState(rawValue: rc)
                            {
                                existing.followed = lc
                            } else if let rc = td["followed"] as? Bool {
                                existing.followed = FollowState.from(rawValue: rc)
                            }
                            if let dr = td["moments_duration"] as? Int {
                                existing.duration = dr
                            }
                            if let gt = td["group_timeline"] as? Bool {
                                existing.groupTimeline = gt
                            }
                            if let cc = td["comments_count"] as? Int {
                                existing.commentsCount = cc
                            }
                            if let dec = td["description"] as? String {
                                existing.description = dec
                            }
                            if let dr = td["updated_at"] as? String {
                                existing.updated_at = dr
                            }
                            if let aId = td["admin_id"] as? String {
                                existing.adminId = aId
                            }
                            existing.state = SynchronizationState(dict: td)
                            
                            tl = existing
                        } else
                        { // set up timeline
                            tl = Timeline(dict: td, parent: nil)
                            owner.timelines.append(tl)
                        }
                        timelines.append(tl)
                    }
                    
                }
            }
            switch request {
            case .TimelineFollowing:
                Storage.session.followingCache = timelines.map { $0.state.uuid! }
                
            case .TimelineTrending:
                Storage.session.trendingCache = timelines.map { $0.state.uuid! }
                
            case .CurrentTimelineFollowing:
                Storage.session.currentTimelineFollowingCache = timelines.map { $0.state.uuid! }
                
            case .CurrentTimelineBlocked:
                Storage.session.currentTimelineBlockedCache = timelines.map { $0.state.uuid! }
                
            default:
                break
            }
            
            Storage.save()
            completion(timelines)
        }
    }
    
    func reloadMoments(completion: Void -> Void) {
        Storage.performRequest(ApiRequest.ViewTimelineVideos(state.uuid!), completion: { (json) -> Void in
            var dirty = false
            if let videos = json["videos"] as? [[String: AnyObject]] {
                //print(videos)
                for v in videos {
                    if let _ = Storage.findMoment(v["id"] as! UUID) {
                        // do nothing
                    } else {
                        // create moment
                        let moment = Moment(dict: v, parent: self)
                        self.moments.append(moment)
                        dirty = true
                    }
                }
            }
            if dirty {
                Storage.save()
            }
            completion()
        })
    }
    
    func like(completion: () -> ()) {
        let new = ++self.likesCount
        self.liked = true
        
        Storage.performRequest(ApiRequest.TimelineLike(state.uuid!), completion: { (json) -> Void in
            if let likes = json["likes"] as? Int {
                self.likesCount = likes
                self.liked = true
            } else {
                self.liked = false
                if self.likesCount == new {
                    self.likesCount--
                }
            }
            Storage.save()
            completion()
        })
    }
    
    func unlike(completion: () -> ()) {
        let new = --self.likesCount
        self.liked = false
        
        Storage.performRequest(ApiRequest.TimelineUnlike(state.uuid!), completion: { (json) -> Void in
            if let likes = json["likes"] as? Int {
                self.likesCount = likes
                self.liked = false
            } else {
                self.liked = true
                if self.likesCount == new {
                    self.likesCount++
                }
            }
            Storage.save()
            completion()
        })
    }
    
    func follow(completion: () -> ()) {
        let new = self.followersCount++
        let oldState = self.followed
        self.followed = .Following
        
        Storage.performRequest(ApiRequest.TimelineFollow(state.uuid!), completion: { (json) -> Void in
            if let followers = json["followers"] as? Int {
                self.followersCount = followers
            } else {
                if self.followersCount == new {
                    self.followersCount++
                }
            }
            if let state = json["state"] as? String {
                switch state {
                case "success":
                    self.followed = .Following
                    Storage.session.followingCache.append(self.uuid!)
                case "following":
                    self.followed = .Following
                case "pending":
                    self.followed = .Pending
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
    
    func unfollow(completion: () -> ()) {
        let new = --self.followersCount
        let oldState = self.followed
        self.followed = .NotFollowing
        
        Storage.performRequest(ApiRequest.TimelineUnfollow(state.uuid!), completion: { (json) -> Void in
            if let followers = json["followers"] as? Int
            {
                self.followersCount = followers
                self.followed = .NotFollowing
                
                Storage.session.followingCache = Storage.session.followingCache.filter { $0 != self.uuid }
            } else {
                self.followed = oldState
                if self.followersCount == new {
                    self.followersCount++
                }
            }
            
            Storage.save()
            completion()
        })
    }
    
    func block(completion: () -> ()) {
        self.blocked = true
        Storage.performRequest(ApiRequest.TimelineBlock(state.uuid!), completion: { (json) -> Void in
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
        Storage.performRequest(ApiRequest.TimelineUnblock(state.uuid!), completion: { (json) -> Void in
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
    
    func download(completion: () -> ()) {
        self.persistent = true
        async {
            Storage.save()
            for m in self.moments {
                if !m.persistent {
                    m.downloadMoment { }
                }
            }
            Storage.save()
        }
    }
    
    func removeDownload(completion: () -> ()) {
        
        self.persistent = false
        async {
            Storage.save()
            for m in self.moments {
                if m.persistent {
                    m.removeMoment { }
                }
            }
            Storage.save()
        }
    }
    
}
