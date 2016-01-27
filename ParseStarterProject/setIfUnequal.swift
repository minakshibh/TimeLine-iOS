//
//  setIfUnequal.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

public func setIfUnequal<Eq: Equatable>(inout variable: Eq, value: Eq) {
    if value != variable {
        variable = value
    }
}
public func setIfUnequal<Eq: Equatable>(inout variable: Eq?, value: Eq?) {
    if value != variable {
        variable = value
    }
}
public func setIfUnequal<Eq: Equatable>(inout variable: Eq?, value: Eq) {
    if value != variable {
        variable = value
    }
}
public func setIfUnequal<Eq: Equatable>(inout variable: Eq!, value: Eq!) {
    switch (variable, value) {
    case (_, nil): break
    case (nil, _): variable = value
    default:
        if value != variable {
            variable = value
        }
    }
}

infix operator =!= { associativity right precedence 90 }
public func =!=<Eq: Equatable>(inout variable: Eq, value: Eq) {
    setIfUnequal(&variable, value: value)
}
public func =!=<Eq: Equatable>(inout variable: Eq?, value: Eq?) {
    setIfUnequal(&variable, value: value)
}
public func =!=<Eq: Equatable>(inout variable: Eq?, value: Eq) {
    setIfUnequal(&variable, value: value)
}
public func =!=<Eq: Equatable>(inout variable: Eq!, value: Eq!) {
    setIfUnequal(&variable, value: value)
}
