//
//  Named.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Named1 {
    var firstName: String { get }
    var lastName: String { get }
   var name: String { get }
    static var prefix: String { get }
}

//extension Timeline: Named1 {
//    static let prefix1 = "#"
//}

extension User: Named1 {
    static let prefix1 = "@"
}

extension Named1 {
    var fullName1: String {
        print("name")
        return Self.prefix + firstName + lastName
    }
}