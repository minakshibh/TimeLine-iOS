//
//  Durationial.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Durational {
    var duration: Int { get }
}

extension Timeline: Durational { }
extension Moment: Durational { }
