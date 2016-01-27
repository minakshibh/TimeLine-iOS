//
//  Pushable.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

/// This is just a convenience protocol for unified pushing identifiers
protocol Pushable: class {
    var pushIdentifier: String { get }
}

extension User: Pushable {
    var pushIdentifier: String {
        return "ShowUser"
    }
}
