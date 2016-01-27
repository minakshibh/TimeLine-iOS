import UIKit

protocol SegueHandlerType {
    typealias SegueIdentifier: RawRepresentable
}

func segueIdentifierForSegue<T: SegueHandlerType where T.SegueIdentifier.RawValue == String>(segue: UIStoryboardSegue) -> T.SegueIdentifier {
    if let identifier = segue.identifier, segueIdentifier = T.SegueIdentifier(rawValue: identifier) {
        return segueIdentifier
    } else {
        fatalError("Unknown identifier \(segue.identifier)")
    }
}

/*extension SegueHandlerType where
    Self: UIViewController,
    SegueIdentifier.RawValue == String
{
    //handleSegue with guard
    // There is a sample project
    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
        segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Unknown identifier \(segue.identifier)") }
        return segueIdentifier
    }
}*/