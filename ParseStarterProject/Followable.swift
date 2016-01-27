//
//  Followable.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Followable {
    var followed: FollowState { get }
    var followersCount: Int { get }

    func follow(completion: () -> ())
    func unfollow(completion: () -> ())
    func followers(completion: ([User]) -> ())
}

class FollowableValue: Followable {
    var followable: Followable

    init(followable: Followable) {
        self.followable = followable
    }

    var followed: FollowState {
        return followable.followed
    }
    var followersCount: Int {
        return followable.followersCount
    }

    func follow(completion: () -> ()) {
        followable.follow(completion)
    }
    func unfollow(completion: () -> ()) {
        followable.unfollow(completion)
    }
    func followers(completion: ([User]) -> ()) {
        followable.followers(completion)
    }
}

extension Timeline: Followable {
    func followers(completion: ([User]) -> ()) {
        guard let uuid = uuid else {
            completion([])
            return
        }
        User.getUsers(.TimelineFollowerList(uuid), completion: completion)
    }
}

extension User: Followable {
    func followers(completion: ([User]) -> ()) {
        guard let uuid = uuid else {
            completion([])
            return
        }
        User.getUsers(.UserFollowerList(uuid), completion: completion)
    }
}

extension Followable {

    func toggleFollowState(completion: () -> ()) {
        let action: (() -> ()) -> ()
        switch self.followed {
        case .Following, .Pending:
            action = self.unfollow
        case .NotFollowing:
            action = self.follow
        }
        action(completion)
    }

}