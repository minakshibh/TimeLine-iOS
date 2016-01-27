//
//  Refreshable.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Refreshable {
    var refreshers: [() -> ()] { get }
}
extension Refreshable {
    func refresh() {
        main {
            for r in self.refreshers {
                r()
            }
        }
    }
}