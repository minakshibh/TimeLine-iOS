//
//  Shareable.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import Foundation

protocol Shareable {
    var sharingActivities: [AnyObject] { get }
}

extension User: Shareable {
    var sharingActivities: [AnyObject] {
        let urlString = lformat(LocalizedString.UserStringShareURL1s, args: name.urlEncoded ?? "")
        let messageString = lformat(LocalizedString.UserStringShareMessage1s, args: name ?? "")
        return [messageString, NSURL(string: urlString)!]
    }
}
extension Timeline: Shareable {
    var sharingActivities: [AnyObject] {
        let urlString = lformat(LocalizedString.TimelineStringShareURL2s, args: parent?.name.urlEncoded ?? "", name.urlEncoded ?? "")
        let messageString = lformat(LocalizedString.TimelineStringShareMessage2s, args: parent?.name ?? "", name ?? "")
        return [messageString, NSURL(string: urlString)!]
    }
}

extension Shareable where Self: UIViewController {

}
