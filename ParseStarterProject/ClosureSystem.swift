import Foundation

/// Stores many weak-referenced closures, and may call all in once
/// Throwing closures are not allowed
public struct ClosureSystem<P, R> {
    
    /// The type of a single closure
    public typealias ClosureType = (P) -> R
    private var elements: [WeakReference<Reference<ClosureType>>]
    
    /// Initiates an empty closure system
    public init() {
        elements = []
    }
    
    /// Executes the system and omits the return value.
    /// Old closures will be called first.
    public func execute(arguments: P) {
        for ref in elements {
            ref.value?.value(arguments)
        }
    }
    
    /// Invokes the system and returns all values.
    /// Old closures will be called first and their values will have lower indices.
    public func invoke(arguments: P) -> [R] {
        return elements.reduce([]) { (var list: [R], ref: WeakReference<Reference<ClosureType>>) in
            if let c = ref.value?.value {
                list.append(c(arguments))
            }
            return list
        }
    }
    
    /// Optimizes the system's memory by removing freed elements.
    public mutating func optimize() {
        elements = elements.filter { (el) -> Bool in
            return el.value?.value != nil
        }
    }
    
    /// Extends the system with given closures.
    public mutating func extend(newElements: [ClosureType]) -> [AnyObject] {
        let resps = newElements.map {
            Reference(value: $0)
        }
        elements.appendContentsOf(resps.map { WeakReference(value: $0) })
        return resps
    }
    
}

private class Reference<T> {
    private var value: T
    
    private init(value: T) {
        self.value = value
    }
}

private class WeakReference<T: AnyObject> {
    private weak var value: T?
    
    private init(value: T) {
        self.value = value
    }
}