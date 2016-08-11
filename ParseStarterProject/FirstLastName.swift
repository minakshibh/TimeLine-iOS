import SWFrameButton

protocol FirstLastName {
    associatedtype TargetBehaviorType: Named1,Named
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel1: UILabel! { get }
    //    var nameLabel1: UILabel! { get }
    //    var lblBio: UILabel! { get }
    //    var lblOthers: UILabel! { get }
    //    var btnWebsite: SWFrameButton! { get }
}

extension FirstLastName {
    
    func refreshFirstLastName() {
        
        //
        //        let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(behaviorTarget?.bio ?? "")")
        //        attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
        //        lblBio.attributedText = attributedTextBio
        ////        lblBio.text =!= behaviorTarget?.bio ?? ""
        
        //        let attributedTextOthers: NSMutableAttributedString = NSMutableAttributedString(string: "Others: \(behaviorTarget?.other ?? "")")
        //        attributedTextOthers.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 6))
        //        lblOthers.attributedText = attributedTextOthers
        ////        lblOthers.text =!= behaviorTarget?.other ?? ""
        
        guard let controller = activeController() else { return }
        if String(controller).rangeOfString("Timeline.TrendingTimelineTableViewController") != nil{
            
            nameLabel1.text =!= "\(behaviorTarget?.fullName1 ?? "" )"
            
        }else{
            //print(behaviorTarget?.fullName1)
            if (behaviorTarget?.fullName1 == " ") {
                nameLabel1.text =!= "\((PFUser.currentUser()?.firstname)!) \((PFUser.currentUser()?.lastname)!) \(TargetBehaviorType.prefix.stringByAppendingString(behaviorTarget?.name ?? ""))"
            }else{
                nameLabel1.text =!= "\(behaviorTarget?.fullName1 ?? "" ) \(TargetBehaviorType.prefix.stringByAppendingString(behaviorTarget?.name ?? ""))"
                
            }
            nameLabel1.simpleSubstring("\(TargetBehaviorType.prefix.stringByAppendingString(behaviorTarget?.name ?? ""))")
        }
        
        
        //        btnWebsite.setTitle(behaviorTarget?.website ?? "", forState: .Normal)
        
    }
}