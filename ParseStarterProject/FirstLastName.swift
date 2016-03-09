
protocol FirstLastName {
    typealias TargetBehaviorType: Named
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel1: UILabel! { get }
    //    var nameLabel1: UILabel! { get }
}

extension FirstLastName {
    func refreshFirstLastName() {
        print("^^^^\(behaviorTarget?.name)")
        
        nameLabel1.text =!= TargetBehaviorType.prefix.stringByAppendingString(behaviorTarget?.name ?? "")
        
    }
}