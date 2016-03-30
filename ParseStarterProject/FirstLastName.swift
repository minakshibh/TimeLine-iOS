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


        let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(behaviorTarget?.bio ?? "")")
        attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
        lblBio.attributedText = attributedTextBio
//        lblBio.text =!= behaviorTarget?.bio ?? ""
        
        let attributedTextOthers: NSMutableAttributedString = NSMutableAttributedString(string: "Others: \(behaviorTarget?.other ?? "")")
        attributedTextOthers.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 6))
        lblOthers.attributedText = attributedTextOthers
//        lblOthers.text =!= behaviorTarget?.other ?? ""

        nameLabel1.text =!= behaviorTarget?.fullName1 ?? ""
        
       
//        btnWebsite.setTitle(behaviorTarget?.website ?? "", forState: .Normal)
        
    }
}