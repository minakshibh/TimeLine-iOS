//
//  Hooking.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Hooking: class {
    var hookingResponsibilities: [AnyObject?] { get set }
    var hookingSetUps: [() -> AnyObject?] { get }
}

extension Hooking {
    func setUpHooking() {
        hookingResponsibilities = hookingSetUps.map { $0() }
    }
    func cleanUpHooking() {
        // TODO: Move!!!
        serialHook.perform(key: .StopAllPlaybacks, argument: ())

        hookingResponsibilities = []
    }
}
