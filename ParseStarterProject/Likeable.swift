//
//  Likeable.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//


protocol Likeable {
    var liked: Bool { get }
    var likesCount: Int { get }

    func like(completion: () -> ())
    func unlike(completion: () -> ())
    func likers(completion: ([User]) -> ())
}

class LikeableValue: Likeable {
    var likeable: Likeable

    init(likeable: Likeable) {
        self.likeable = likeable
    }

    var liked: Bool {
        return likeable.liked
    }
    var likesCount: Int {
        return likeable.likesCount
    }

    func like(completion: () -> ()) {
        likeable.like(completion)
    }
    func unlike(completion: () -> ()) {
        likeable.unlike(completion)
    }
    func likers(completion: ([User]) -> ()) {
        likeable.likers(completion)
    }
}

extension Timeline: Likeable {
    func likers(completion: ([User]) -> ()) {
        guard let uuid = uuid else {
            completion([])
            return
        }
        main{
        User.getUsers(.TimelineLikersList(uuid), completion: completion)
        }
    }
}
extension User: Likeable {
    func likers(completion: ([User]) -> ()) {
        guard let uuid = uuid else {
            completion([])
            return
        }
        User.getUsers(.UserLikersList(uuid), completion: completion)
    }
}

extension Likeable {

    func toggleLiked(completion: () -> ()) {
        let action: (() -> ()) -> ()
        switch self.liked {
        case true:
            action = self.unlike
        case false:
            action = self.like
        }
        action(completion)
    }
    
}