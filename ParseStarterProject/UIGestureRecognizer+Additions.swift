import UIKit

public extension UITapGestureRecognizer {
    
    public var location: CGPoint {
        return self.locationInView(self.view)
    }
    
}