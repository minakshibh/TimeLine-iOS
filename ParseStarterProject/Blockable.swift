//
//  Blockable.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Blockable {
    // TODO: Add support for ConclurerHook

    var isBlocked: Bool { get }

    func block(completion: () -> ())
    func unblock(completion: () -> ())
}

extension User: Blockable {
    var isBlocked: Bool {
        return blocked
    }
}

extension Timeline: Blockable {
    var isBlocked: Bool {
        return blocked
    }
}
