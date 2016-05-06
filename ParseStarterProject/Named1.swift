//
//  Named.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Named1 {
    var userfullName: String { get }
    var lastName: String { get }
    var name: String { get }
    var bio: String { get }
    var other: String { get }
    var website: String { get }
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
        //print("fullName1")
        return  userfullName
    }
    var bio: String {
        var bioStr = bio
        bioStr = "Bio: \(bioStr)"
        return bioStr
    }
    var other: String {
        //print("other")
        return  "Other: \(other)"
    }
    var website: String {
        //print("website")
        return  website
    }

}