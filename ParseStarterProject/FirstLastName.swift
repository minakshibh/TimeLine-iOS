
protocol FirstLastName {
    typealias TargetBehaviorType: Named1
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel1: UILabel! { get }
    //    var nameLabel1: UILabel! { get }
    var lblBio: UILabel! { get }
    var lblOthers: UILabel! { get }
}

extension FirstLastName {
    
    func refreshFirstLastName() {

        var bioStr:String = ""
                if NSUserDefaults.standardUserDefaults().valueForKey("user_bio") != nil {
                    bioStr = "\(NSUserDefaults.standardUserDefaults().valueForKey("user_bio")!)"
                    let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(bioStr)")
                    attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
                    lblBio.attributedText = attributedTextBio
                }
                if NSUserDefaults.standardUserDefaults().valueForKey("user_bio") == nil {
                    bioStr = ""
                    lblBio.text = bioStr
                }
                
                var otherStr:String = ""
                if NSUserDefaults.standardUserDefaults().valueForKey("user_other") != nil {
                    otherStr = "\(NSUserDefaults.standardUserDefaults().valueForKey("user_other")!)"
                    let attributedTextOther: NSMutableAttributedString = NSMutableAttributedString(string: "Other: \(otherStr)")
                    attributedTextOther.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 6))
                    lblOthers.attributedText = attributedTextOther
                }
                if NSUserDefaults.standardUserDefaults().valueForKey("user_other") == nil {
                    otherStr = ""
                    lblOthers.text = otherStr
                }

        nameLabel1.text =!= behaviorTarget?.fullName1 ?? ""
        
    }
}