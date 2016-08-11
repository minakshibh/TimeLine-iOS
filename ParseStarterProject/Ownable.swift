//
//  Ownable.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol OwnableTrait {
    associatedtype ParentType
    var parent: ParentType? { get }
}
protocol Ownable {
    associatedtype ParentType
    var parent: ParentType? { get }
    var isOwn: Bool { get }
}


extension OwnableTrait where Self.ParentType: Ownable {
    var isOwn: Bool {
        return parent?.isOwn ?? false
    }
}

extension User: Ownable {
    var isOwn: Bool {
        //print("selfUuid: \(uuid)  &  Current user uuid: \(Storage.session.currentUser?.uuid)")
        if let selfUuid = uuid, currentUuid = Storage.session.currentUser?.uuid where selfUuid == currentUuid {
            return true
        } else {
            return false
        }
    }
}

extension Timeline: OwnableTrait {

}
extension Timeline: Ownable { }
extension Moment: OwnableTrait, Ownable {

}

