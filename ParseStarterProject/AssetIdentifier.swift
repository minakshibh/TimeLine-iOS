import UIKit

extension UIImage {
    
    enum AssetIdentifier: String {
        case AppIcon = "AppIcon"
        case LaunchImage = "LaunchImage"
        
        case Background = "Background"
        case Logo = "Logo"
        
        case BackIndicator = "Back to previous screen"
        
        case DeleteActive = "Delete Active"
        case SendToTimeline = "Send to Timeline"
        case SendToTimelineBar = "Send to Timeline Bar"
        case Trim = "Trim"
        
        case ProfileHeart = "Profile Heart"
        
        case New = "New Timeline"
        
        case Heart = "Heart"
        case Unheart = "Unheart"
        case Follow = "Follow"
        case Unfollow = "Unfollow"
        case FollowTimeline = "Follow Timeline"
        case UnfollowTimeline = "UnFollow Timeline"
        case Delete = "Delete"
        case Report = "Flag"
        case Unreport = "Unflag"
        case Play = "Play"
        case Share = "Share"
        case Download = "Download"
        case RemoveDownload = "Remove-Download"
        
        case Approve = "Approve"
        case Decline = "Decline"

        case LikeableButton = "love"
        case CommentableButton = "comments"
        case FollowableButton = "follower"

        case DefaultUserProfile = "default-user-profile"
        
        case likeImage = "likeImage"
        
        case dislikeImage = "dislikeImage"
        
        
        case whiteHeart = "whiteHeart"
        case RedHeart = "RedHeart"
        
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
    
}