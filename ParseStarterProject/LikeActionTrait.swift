//
//  LikableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//


protocol LikeActionTrait { }
extension LikeActionTrait {

    func toggleLike(likable: Likable, completion: (Bool) -> ()) {
        let action = likable.liked ? likable.like : likable.unlike
        action { () -> () in
            completion(likable.liked)
        }
    }

}