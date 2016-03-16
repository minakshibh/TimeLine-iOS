
protocol FirstLastName {
    typealias TargetBehaviorType: Named1
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel1: UILabel! { get }
    //    var nameLabel1: UILabel! { get }
}

extension FirstLastName {
    
    func refreshFirstLastName() {
        nameLabel1.text =!= behaviorTarget?.fullName1 ?? ""
        
    }
}