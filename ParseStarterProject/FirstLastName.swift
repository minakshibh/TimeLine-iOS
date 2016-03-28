import SWFrameButton

protocol FirstLastName {
    typealias TargetBehaviorType: Named1
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel1: UILabel! { get }
    //    var nameLabel1: UILabel! { get }
    var lblBio: UILabel! { get }
    var lblOthers: UILabel! { get }
//    var btnWebsite: SWFrameButton! { get }
}

extension FirstLastName {
    
    func refreshFirstLastName() {


        lblBio.text =!= behaviorTarget?.bio ?? ""

        lblOthers.text =!= behaviorTarget?.other ?? ""

        nameLabel1.text =!= behaviorTarget?.fullName1 ?? ""
        
       
//        btnWebsite.setTitle(behaviorTarget?.website ?? "", forState: .Normal)
        
    }
}