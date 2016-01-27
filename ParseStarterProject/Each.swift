//
//  Each.swift
//  Timeline
//
//  Created by Valentin Knabel on 09.11.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import Foundation

extension CollectionType {
    /// - Complexity: O(N).
    public func each<T>(@noescape transform: (Self.Generator.Element) throws -> T) rethrows {
        _ = try self.map(transform)
    }
}