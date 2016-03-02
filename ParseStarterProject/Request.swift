//
//  Request.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

typealias UUID = String
typealias PAGE_ID = String
typealias PARAMS = String
typealias members = String
typealias groupdescription = String
typealias owner = String
typealias timeLinename = String

enum ApiRequest {
    

//    private static let baseUrl = NSURL(string: "http://timeline-server.elasticbeanstalk.com")!
    private static let baseUrl = NSURL(string: "http://54.191.110.86")!

    /// GET /api/user/get_token
    /// Header: X-Parse-Session-Token String
    case GetToken(String)
    
    /// GET /api/timeline/:id
    /// id: UUID of the Timeline
    case ViewTimeline(UUID)
    /// GET /api/timeline/:id/videos
    /// id: UUID of the Timeline
    case ViewTimelineVideos(UUID)
    /// POST /api/timeline/create
    /// name: Name of the Timeline
    /// user_id: UUID of the user
    case CreateTimeline(String,groupdescription)
    
    case CreateGroupTimeline(timeLinename,members,groupdescription)
    /// GET /api/video/:id
    /// id: UUID of the video
    case ViewVideo(UUID)
    /// PUT /api/video/create
    /// video: video data
    /// timeline_id: UUID of the Timeline
    case CreateVideo(NSData, UUID)
    /// DELETE /api/timeline/:uuid/delete
    case DestroyTimeline(UUID)
    
    /// POST /api/user/update
    case UserUpdate
    /// POST /api/user/delete
    case UserDelete
    /// GET /api/user/me
    case UserMe
    /// GET /api/user/:id
    case UserProfile(UUID)
    /// POST /api/user/settings
    case UserSettings(String, Bool)
    
    /// GET /api/timeline/me
    case TimelineMe
    /// GET /api/timeline/user/:user_id
    case TimelineUser(UUID)
    /// GET /api/timeline/id/comments
    case TimelineComments(UUID)
    case TimelinePostComment(UUID,PARAMS)
    case MomentPostComment(UUID,PARAMS)
    /// GET /api/user/my_followers
    case GetTagUsers
    /// GET /api/video/id/comments
    case MomentComments(UUID)
    /// GET /timeline/trending
    case TimelineTrending
    
    /// GET /timeline/following
    case TimelineFollowing
    
    /// POST /api/timeline/:id/like
    case TimelineLike(UUID)
    /// POST /api/timeline/:id/unlike
    case TimelineUnlike(UUID)
    /// POST /api/timeline/:id/follow
    case TimelineFollow(UUID)
    /// POST /api/timeline/:id/unfollow
    case TimelineUnfollow(UUID)
    
    /// POST /api/user/:id/like
    case UserLike(UUID)
    /// POST /api/user/:id/unlike
    case UserUnlike(UUID)
    /// POST /api/user/:id/follow
    case UserFollow(UUID)
    /// POST /api/user/:id/unfollow
    case UserUnfollow(UUID)
    
    /// POST /api/user/:id/approve
    case UserApprove(UUID)
    /// POST /api/user/:id/decline
    case UserDecline(UUID)
    /// POST /api/user/:id/block
    case UserBlock(UUID)
    /// POST /api/user/:id/unblock
    case UserUnblock(UUID)
    /// POST /api/timeline/:id/block
    case TimelineBlock(UUID)
    /// POST /api/timeline/:id/unblock
    case TimelineUnblock(UUID)
    
    /// GET /api/search/:searchterm
    case Search(String)
    
    /// GET /api/user/followers
    case CurrentUserFollowers
    /// GET /api/user/following
    case CurrentUserFollowing
    /// GET /api/timeline/following
    case CurrentTimelineFollowing
    /// GET /api/timeline/followers
    case CurrentTimelineFollowers
    /// GET /api/timeline/:id/followers
    case SpecificTimelineFollowing(UUID)
    /// GET /api/user/blocked
    case CurrentUserBlocked
    /// GET /api/timeline/blocked
    case CurrentTimelineBlocked
    /// GET /api/user/follow_queue
    case CurrentUserPending
    
    /// GET /api/user/notifications
    /// - parameter date:
    case UserNotifications
    
    case UserAllNotifications(PAGE_ID)
    
    /// POST /api/user/increment_timelines
    case IncrementTimelineMax

    /// GET /api/timeline/:id/followers
    case TimelineFollowerList(UUID)
    /// GET /api/timeline/:id/likers
    case TimelineLikersList(UUID)

    /// GET /api/user/:id/followers
    case UserFollowerList(UUID)
    /// GET /api/user/:id/likers
    case UserLikersList(UUID)
    
    case getFacebookInfo(String)
    
//    case getFacebookImage
    case getFacebookImage(String)
    
    var urlRequest: NSMutableURLRequest {
        let urlString: String
        let urlRequest = NSMutableURLRequest()
        print(Storage.session.webToken)
        urlRequest.setValue(Storage.session.webToken, forHTTPHeaderField: "X-Timeline-Authentication")
        
        switch self {
        case let .GetToken(parse):
            urlString = "/api/user/get_token"
            urlRequest.HTTPMethod = "GET"
            urlRequest.setValue(parse.urlEncoded, forHTTPHeaderField: "X-Parse-Session-Token")
            
        case let .ViewTimeline(uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
            
        case let .ViewTimelineVideos(uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/videos"
            urlRequest.HTTPMethod = "GET"
            
        case let .DestroyTimeline(uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/"
            urlRequest.HTTPMethod = "DELETE"
            
        case let .CreateTimeline(name,groupdescription):
//            urlString = "/api/timeline/create"
//            urlRequest.HTTPMethod = "POST"
////            description
//            urlRequest.HTTPBody = "name=\(name.urlEncoded)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            let bodyData = "name=\(name.urlEncoded)&description=\(groupdescription.urlEncoded)"
            urlString = "/api/timeline/create?\(bodyData)"
            urlRequest.HTTPMethod = "POST"
            
        case let .CreateGroupTimeline(timeLinename,members,groupdescription):
            let bodyData = "name=\(timeLinename.urlEncoded)&participants=\(members.urlEncoded)&description=\(groupdescription.urlEncoded)&group_timeline=1"
            urlString = "/api/timeline/create?\(bodyData)"
            urlRequest.HTTPMethod = "POST"
            
        case let .ViewVideo(uuid):
            urlString = "/api/video/\(uuid.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
            
        case .CreateVideo(_, _):
            urlString = "/api/video/create"
            urlRequest.HTTPMethod = "PUT"
            
        case .UserUpdate:
            urlString = "/api/user/update"
            urlRequest.HTTPMethod = "POST"
            
        case .UserDelete:
            urlString = "/api/user/delete"
            urlRequest.HTTPMethod = "POST"
            
        case .UserMe:
            urlString = "/api/user/me"
            urlRequest.HTTPMethod = "GET"
            
        case let .UserProfile(uuid):
            urlString = "/api/user/\(uuid.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
            
        case let .UserSettings(option, value):
            urlString = "/api/user/settings"
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = "\(option.urlEncoded)=\(value.description.urlEncoded)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
        case .TimelineMe:
            urlString = "/api/timeline/me"
            urlRequest.HTTPMethod = "GET"
            
        case .TimelineUser(let uuid):
            urlString = "/api/timeline/user/\(uuid.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
        
        case .TimelineComments(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/comments"
            urlRequest.HTTPMethod = "GET"
            
        case .TimelinePostComment(let uuid,let params):
            urlString = "/api/timeline/\(uuid.urlEncoded)/comment"
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = "comment=\(params.urlEncoded)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        case .MomentPostComment(let uuid,let params):
            urlString = "/api/video/\(uuid.urlEncoded)/comment"
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = "comment=\(params.urlEncoded)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        case .MomentComments(let uuid):
            urlString = "/api/video/\(uuid.urlEncoded)/comments"
            urlRequest.HTTPMethod = "GET"
            
        case .TimelineFollowing:
            urlString = "/api/timeline/following"
            
        case .TimelineTrending:
            urlString = "/api/timeline/trending"
            
        case .TimelineLike(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/like"
            urlRequest.HTTPMethod = "POST"
            
        case .TimelineUnlike(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/unlike"
            urlRequest.HTTPMethod = "POST"
            
        case .TimelineFollow(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/follow"
            urlRequest.HTTPMethod = "POST"
            
        case .TimelineUnfollow(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/unfollow"
            urlRequest.HTTPMethod = "POST"
            
        case .UserLike(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/like"
            urlRequest.HTTPMethod = "POST"
            
        case .UserUnlike(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/unlike"
            urlRequest.HTTPMethod = "POST"
            
        case .UserFollow(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/follow"
            urlRequest.HTTPMethod = "POST"
            
        case .UserUnfollow(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/unfollow"
            urlRequest.HTTPMethod = "POST"
            
        case .Search(let term):
            urlString = "/api/search/\(term.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
            
        case .IncrementTimelineMax:
            urlString = "/api/user/increment_timelines"
            urlRequest.HTTPMethod = "POST"
        
        case .UserApprove(let UUID):
            urlString = "/api/user/\(UUID.urlEncoded)/accept"
            urlRequest.HTTPMethod = "POST"
            
        case .UserDecline(let UUID):
            urlString = "/api/user/\(UUID.urlEncoded)/decline"
            urlRequest.HTTPMethod = "POST"
            
        case .UserBlock(let UUID):
            urlString = "/api/user/\(UUID.urlEncoded)/block"
            urlRequest.HTTPMethod = "POST"
            
        case .UserUnblock(let UUID):
            urlString = "/api/user/\(UUID.urlEncoded)/unblock"
            urlRequest.HTTPMethod = "POST"
            
        case .TimelineBlock(let UUID):
            urlString = "/api/timeline/\(UUID.urlEncoded)/block"
            urlRequest.HTTPMethod = "POST"
            
        case .TimelineUnblock(let UUID):
            urlString = "/api/timeline/\(UUID.urlEncoded)/unblock"
            urlRequest.HTTPMethod = "POST"
            
        case CurrentUserFollowers:
            urlString = "/api/user/followers"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentUserFollowing:
            urlString = "/api/user/following"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentTimelineFollowing:
            urlString = "/api/timeline/following"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentTimelineFollowers:
            urlString = "/api/timeline/followers"
            urlRequest.HTTPMethod = "GET"
            
        case SpecificTimelineFollowing(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/followers"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentUserBlocked:
            urlString = "/api/user/blocked"
            urlRequest.HTTPMethod = "GET"
            
        case .GetTagUsers:
            urlString = "api/user/my_followers"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentTimelineBlocked:
            urlString = "/api/timeline/blocked"
            urlRequest.HTTPMethod = "GET"
            
        case CurrentUserPending:
            urlString = "/api/user/follow_queue"
            urlRequest.HTTPMethod = "GET"
            
        case .UserNotifications:
            let dateString = SynchronizationState.formatter.stringFromDate(Storage.session.notificationDate ?? NSDate())
            urlString = "/api/user/notifications?date=\(dateString.urlEncoded)"
            urlRequest.HTTPMethod = "GET"
            
        case .UserAllNotifications(let page_id):
            let dateString = SynchronizationState.formatter.stringFromDate(Storage.session.notificationDate ?? NSDate())
            urlString = "/api/user/timeline_notifications?date=\(dateString.urlEncoded)&page_id=\(page_id)"
//            urlString = "/api/user/notifications?date=2016-02-11T12%3A46%3A24.461Z"
            urlRequest.HTTPMethod = "GET"

        case .TimelineFollowerList(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/followers"
            urlRequest.HTTPMethod = "GET"
        case .TimelineLikersList(let uuid):
            urlString = "/api/timeline/\(uuid.urlEncoded)/likers"
            urlRequest.HTTPMethod = "GET"

        case .UserFollowerList(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/followers"
            urlRequest.HTTPMethod = "GET"
        case .UserLikersList(let uuid):
            urlString = "/api/user/\(uuid.urlEncoded)/likers"
            urlRequest.HTTPMethod = "GET"
            
        case .getFacebookInfo(let token):
            urlString = "https://graph.facebook.com/me?access_token=\(token)&fields=email,name,id"
            urlRequest.HTTPMethod = "GET"
            
        case .getFacebookImage(let facebookId):
            urlString = "https://graph.facebook.com/\(facebookId)/picture?type=large&return_ssl_resources=1"
            urlRequest.HTTPMethod = "GET"

            
        }
        urlRequest.URL = NSURL(string: urlString, relativeToURL: ApiRequest.baseUrl)
        return urlRequest
    }
    
}


extension NSURLSession {
    
    func taskWith(request: ApiRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionTask {
        switch request {
        case .CreateVideo(_, _):
            let mr = request.urlRequest
            return self.dataTaskWithRequest(mr, completionHandler: completionHandler)
            //return self.uploadTaskWithRequest(mr, fromData: data, completionHandler: completionHandler)
        default:
            return self.dataTaskWithRequest(request.urlRequest, completionHandler: completionHandler)
        }
    }
    
}

