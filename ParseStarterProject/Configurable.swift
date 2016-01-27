import Foundation

protocol Configurable {
    
    init<T>(configure: (Self) -> T)
    
}
