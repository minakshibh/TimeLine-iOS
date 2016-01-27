//
//  Named.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Named {
    var name: String { get }
    static var prefix: String { get }
}

extension Timeline: Named {
    static let prefix = "#"
}

extension User: Named {
    static let prefix = "@"
}

extension Named {
    var fullName: String {
        return Self.prefix + name
    }
}