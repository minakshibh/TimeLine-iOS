//
//  Localization.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

protocol Localized {
    typealias RawType
    var localized: RawType { get }
}

enum LocalizedString: String, Localized {
    
    // MARK: Settings License
    case SettingsFormatLicenseContainer2s = "Settings-Format-License-Container-Name:%@-License:%@"
    
    // MARK: Settings Support
    case SettingsStringSupportURL = "Settings-String-Support-URL"
    
    // MARK: Blocking
    case TimelineAlertBlockTitle = "Timeline-Alert-Block-Title"
    case TimelineAlertBlockMessage1s = "Timeline-Alert-Block-Message-Name:%@"
    case TimelineAlertBlockActionCancel = "Timeline-Alert-Block-Action-Cancel"
    case TimelineAlertBlockActionBlock = "Timeline-Alert-Block-Action-Block"
    
    case UserAlertBlockTitle = "User-Alert-Block-Title"
    case UserAlertBlockMessage1s = "User-Alert-Block-Message-Name:%@"
    case UserAlertBlockActionCancel = "User-Alert-Block-Action-Cancel"
    case UserAlertBlockActionBlock = "User-Alert-Block-Action-Block"
    
    // MARK: Unblocking
    case TimelineAlertUnblockTitle = "Timeline-Alert-Unblock-Title"
    case TimelineAlertUnblockMessage1s = "Timeline-Alert-Unblock-Message-Name:%@"
    case TimelineAlertUnblockActionCancel = "Timeline-Alert-Unblock-Action-Cancel"
    case TimelineAlertUnblockActionUnblock = "Timeline-Alert-Unblock-Action-Unblock"
    
    case UserAlertUnblockTitle = "User-Alert-Unblock-Title"
    case UserAlertUnblockMessage1s = "User-Alert-Unblock-Message-Name:%@"
    case UserAlertUnblockActionCancel = "User-Alert-Unblock-Action-Cancel"
    case UserAlertUnblockActionUnblock = "User-Alert-Unblock-Action-Unblock"
    
    // MARK: Capture
    case CaptureAuthorizationFailureTitle = "Capture-Authorization-Failure-Title"
    case CaptureAuthorizationFailureMessage = "Capture-AuthorizationFailure-Message"
    case CaptureAuthorizationFailureDismiss = "Capture-AuthorizationFailure-Dismiss"
    
    case CaptureRecordButtonTitleStart = "Capture-Record-Button-Start-Title"
    case CaptureRecordButtonTitleStop = "Capture-Record-Button-Stop-Title"
    
    // MARK: Login
    case LoginAlertWaitTitle = "Login-Alert-Wait-Title"
    
    // MARK: Session Expired
    case SessionAlertExpiredTitle = "Session-Alert-Expired-Title"
    case SessionAlertExpiredMessage = "Session-Alert-Expired-Message"
    case SessionAlertExpiredActionDismiss = "Session-Alert-Expired-Action-Dismiss"
    
    // MARK: Settings Logout
    case SettingsAlertLogoutTitle = "Settings-Alert-Logout-Title"
    case SettingsAlertLogoutMessage = "Settings-Alert-Logout-Message"
    case SettingsAlertLogoutActionCancel = "Settings-Alert-Logout-Action-Cancel"
    case SettingsAlertLogoutActionLogout = "Settings-Alert-Logout-Action-Logout"
    
    // MARK: Settings Delete
    case SettingsAlertDeleteTitle = "Settings-Alert-Delete-Title"
    case SettingsAlertDeleteMessage = "Settings-Alert-Delete-Message"
    case SettingsAlertDeleteActionCancel = "Settings-Alert-Delete-Action-Cancel"
    case SettingsAlertDeleteActionDelete = "Settings-Alert-Delete-Action-Delete"
    
    // MARK: Settings Email
    case SettingsPlaceholderEmailText = "Settings-Placeholder-Email-Text"
    
    case SettingsAlertEmailMissingTitle = "Settings-Alert-Email-Missing-Title"
    case SettingsAlertEmailMissingMessage = "Settings-Alert-Email-Missing-Message"
    case SettingsAlertEmailMissingActionDismiss = "Settings-Alert-Email-Missing-Action-Dismiss"
    
    // MARK: Settings Password
    case SettingsAlertPasswordErrorTitle = "Settings-Alert-Password-Error-Title"
    case SettingsAlertPasswordErrorMessage = "Settings-Alert-Password-Error-Message"
    case SettingsAlertPasswordErrorActionDismiss = "Settings-Alert-Password-Error-Action-Dismiss"
    
    // MARK: Settings Image
    case SettingsSheetImageSourceTitle = "Settings-Sheet-Image-Source-Title"
    case SettingsSheetImageSourceMessage = "Settings-Sheet-Image-Source-Message"
    case SettingsSheetImageSourceActionCamera = "Settings-Sheet-Image-Source-Action-Camera"
    case SettingsSheetImageSourceActionLibrary = "Settings-Sheet-Image-Source-Action-Library"
    case SettingsSheetImageSourceActionCancel = "Settings-Sheet-Image-Source-Action-Cancel"
    
    // MARK: Settings Timelines Public
    case SettingsAlertTimelinesPublicErrorTitle = "Settings-Alert-TimelinesPublic-Error-Title"
    case SettingsAlertTimelinesPublicErrorActionDismiss = "Settings-Alert-TimelinesPublic-Error-Action-Dismiss"
    
    // MARK: Settings Followers Approve
    case SettingsAlertFollowersApproveErrorTitle = "Settings-Alert-FollowersApprove-Error-Title"
    case SettingsAlertFollowersApproveErrorActionDismiss = "Settings-Alert-FollowersApprove-Error-Action-Dismiss"
    
    // MARK: Settings Share
    case SettingsStringShareMessage = "Settings-String-Share-Message"
    case SettingsStringShareURL = "Settings-String-Share-URL"
    case SettingInternetErrorTitle = "Setting-Internet-Error-Title"
    case SettingInternetErrorMessage = "Setting-Internet-Error-Message"
    case SettinginternetErrorActionDismiss = "Setting-Internet-Error-Action-Dismiss"
    
    // MARK: Timeline Deletion
    case TimelineAlertDeleteWaitTitle = "Timeline-Alert-Delete-Wait-Title"
    case TimelineAlertDeleteWaitMessage = "Timeline-Alert-Delete-Wait-Message"
    
    case TimelineAlertDeleteErrorTitle = "Timeline-Alert-Delete-Error-Title"
    case TimelineAlertDeleteErrorActionDismiss = "Timeline-Alert-Delete-Error-Action-Dismiss"
    
    case TimelineAlertDeleteConfirmTitle = "Timeline-Alert-Delete-Confirm-Title"
    case TimelineAlertDeleteConfirmMessage = "Timeline-Alert-Delete-Confirm-Message"
    case TimelineAlertDeleteConfirmActionDelete = "Timeline-Alert-Delete-Confirm-Action-Delete"
    case TimelineAlertDeleteConfirmActionCancel = "Timeline-Alert-Delete-Confirm-Action-Cancel"
    
    // MARK: Timeline Creation
    case TimelineAlertCreateMissingTitle = "Timeline-Alert-Create-Missing-Title"
    case TimelineAlertCreateMissingMessage = "Timeline-Alert-Create-Missing-Message"
    case TimelineAlertCreateMissingDismiss = "Timeline-Alert-Create-Missing-Dismiss"
    case TimelineAlertCreateMissingDetailMessage = "Timeline-Alert-Create-Missing-Detail-Message"

    case TimelineAlertCreateErrorTitle = "Timeline-Alert-Create-Error-Title"
    case TimelineAlertCreateErrorActionDismiss = "Timeline-Alert-Create-Error-Action-Dismiss"
    
    // MARK: Timeline Cell
    case TimelineButtonCellPendingTitle = "Timeline-Button-Cell-Pending-Title"
    
    // MARK: Timeline Limit
    case TimelineAlertLimitErrorTitle = "Timeline-Alert-Limit-Error-Title"
    case TimelineAlertLimitErrorDefault = "Timeline-Alert-Limit-Error-Default"
    case TimelineAlertLimitErrorActionLater = "Timeline-Alert-Limit-Error-Action-Later"
    case TimelineAlertLimitErrorActionRetry = "Timeline-Alert-Limit-Error-Action-Retry"
    
    case TimelineAlertLimitErrorActionDismiss = "Timeline-Alert-Limit-Error-Action-Dismiss"
    
    case TimelineAlertLimitRequiredTitle = "Timeline-Alert-Limit-Required-Title"
    case TimelineAlertLimitRequiredMessage = "Timeline-Alert-Limit-Required-Message"
    case TimelineAlertLimitRequiredActionUpgrade = "Timeline-Alert-Limit-Required-Action-Upgrade"
    case TimelineAlertLimitRequiredActionCancel = "Timeline-Alert-Limit-Required-Action-Cancel"
    
    // MARK: Timeline Share
    case TimelineStringShareMessage2s = "Timeline-String-Share-Message-User:%@-Timeline:%@"
    case TimelineStringShareURL2s = "Timeline-String-Share-URL-User:%@-Timeline:%@"
    
    // MARK: Timeline Share
    case UserStringShareMessage1s = "User-String-Share-Message-User:%@"
    case UserStringShareURL1s = "User-String-Share-URL-User:%@"
    
    // MARK: Moment Deletion
    case MomentAlertDeleteConfirmTitle = "Moment-Alert-Delete-Confirm-Title"
    case MomentAlertDeleteConfirmMessage = "Moment-Alert-Delete-Confirm-Message"
    case MomentAlertDeleteConfirmActionCancel = "Moment-Alert-Delete-Confirm-Action-Cancel"
    case MomentAlertDeleteConfirmActionDelete = "Moment-Alert-Delete-Confirm-Action-Delete"
    
    // MARK: Moment Trim
    case MomentAlertTrimErrorTitle = "Moment-Alert-Trim-Error-Title"
    case MomentAlertTrimErrorActionDismiss = "Moment-Alert-Trim-Error-Action-Dismiss"
    
    case MomentAlertTrimKeepTitle = "Moment-Alert-Trim-Keep-Title"
    case MomentAlertTrimKeepMessage = "Moment-Alert-Trim-Keep-Message"
    case MomentAlertTrimKeepActionKeep = "Moment-Alert-Trim-Keep-Action-Keep"
    case MomentAlertTrimKeepActionDelete = "Moment-Alert-Trim-Keep-Action-Delete"
    
    // MARK: Moment Upload
    case MomentAlertUploadErrorTitle = "Moment-Alert-Upload-Error-Title"
    case MomentAlertUploadErrorMessageDefault = "Moment-Alert-Upload-Error-Message-Default"
    case MomentAlertUploadExceedTenseconds = "Moment-Alert-Upload-Exceed-Tenseconds"
    case MomentAlertUploadErrorActionDismiss = "Moment-Alert-Upload-Error-Action-Dismiss"
    
    // MARK: Moment Overlay
    case MomentAlertOverlayNoneTitle = "Moment-Alert-Overlay-None-Title"
    case MomentAlertOverlayNoneMessage = "Moment-Alert-Overlay-None-Message"
    case MomentAlertOverlayNoneActionSave = "Moment-Alert-Overlay-None-Action-Save"
    case MomentAlertOverlayNoneActionDismiss = "Moment-Alert-Overlay-None-Action-Dismiss"
    
    // MARK: Formats
    case DurationFormatSeconds1d = "Duration-Format-Seconds-%@"
    case DurationFormatLimitedSeconds1d = "Duration-Format-Limited-Seconds-%@"
    
    /* MARK: - 1.0.39 */
    /* MARK: Timeline Download */
    case TimelineAlertDownloadInfoTitle = "Timeline-Alert-Download-Info-Title"
    case TimelineAlertDownloadInfoMessage1s = "Timeline-Alert-Download-Info-Message-Timeline:%@"
    case TimelineAlertDownloadInfoActionDismiss = "Timeline-Alert-Download-Info-Action-Dismiss"
    case TimelineAlertDownloadInfoActionDownload = "Timeline-Alert-Download-Info-Action-Download"
    
    /* MARK: - 1.0.41 */
    /* MARK: Timeline Playback Errors */
    case TimelineAlertBlockedTimelineTitle1s = "Timeline-Alert-BlockedTimeline-Title-Timeline:%@"
    case TimelineAlertBlockedTimelineMessage2s = "Timeline-Alert-BlockedTimeline-Message-User:%@-Timeline:%@"
    case TimelineAlertBlockedTimelineActionDismiss = "Timeline-Alert-BlockedTimeline-Action-Dismiss"
    
    case TimelineAlertBlockedUserTitle1s = "Timeline-Alert-BlockedUser-Title-User:%@"
    case TimelineAlertBlockedUserMessage2s = "Timeline-Alert-BlockedUser-Message-User:%@-Timeline:%@"
    case TimelineAlertBlockedUserActionDismiss = "Timeline-Alert-BlockedUser-Action-Dismiss"
    
    case TimelineAlertNotPublicTitle1s = "Timeline-Alert-NotPublic-Title-User:%@"
    case TimelineAlertNotPublicMessage1s = "Timeline-Alert-NotPublic-Message-User:%@"
    case TimelineAlertNotPublicActionDismiss = "Timeline-Alert-NotPublic-Action-Dismiss"

    // MARK: - 1.0.75
    // TimelineMoreButtonBehaviorSheet
    case TimelineSheetMoreButtonTitle1s = "Timeline-Sheet-More-Button-Title:%@"
    case TimelineSheetMoreButtonMessage = "Timeline-Sheet-More-Button-Message"
    case TimelineSheetMoreButtonCancel = "Timeline-Sheet-More-Button-Cancel"
    case TimelineSheetMoreButtonShare = "Timeline-Sheet-More-Button-Share"
    case TimelineSheetMoreButtonDelete = "Timeline-Sheet-More-Button-Delete"
    case TimelineSheetMoreButtonBlock = "Timeline-Sheet-More-Button-Block"
    case TimelineSheetMoreButtonUnblock = "Timeline-Sheet-More-Button-Unblock"

    // MARK: - 1.0.76
    case TimelineSheetMoreButtonUser1s = "Timeline-Sheet-More-Button-User:%@"

    // MARK: - 1.0.77
    case UserSheetMoreButtonTitle1s = "User-Sheet-More-Button-Title:%@"
    case UserSheetMoreButtonMessage = "User-Sheet-More-Button-Message"
    case UserSheetMoreButtonCancel = "User-Sheet-More-Button-Cancel"
    case UserSheetMoreButtonShare = "User-Sheet-More-Button-Share"
    case UserSheetMoreButtonBlock = "User-Sheet-More-Button-Block"
    case UserSheetMoreButtonUnblock = "User-Sheet-More-Button-Unblock"

    // MARK: - 1.0.78
    case TimelineSheetMoreButtonAdd = "Timeline-Sheet-More-Button-Add"
    case TimelineSheetMoreButtonDownload = "Timeline-Sheet-More-Button-Download"
    case TimelineSheetMoreButtonNoDownload = "Timeline-Sheet-More-Button-No-Download"

    // MARK: - 1.0.79
    case UserButtonRespondTitle = "User-Button-Respond-Title"
    case UserSheetRespondTitle1s = "User-Sheet-Respond-Title:%@"
    case UserSheetRespondMessage = "User-Sheet-Respond-Message"
    case UserSheetRespondApprove = "User-Sheet-Respond-Approve"
    case UserSheetRespondDecline = "User-Sheet-Respond-Decline"
    case UserSheetRespondCancel = "User-Sheet-Respond-Cancel"

    // MARK: - 1.0.80
    case UserSheetMoreButtonFollowers = "User-Sheet-More-Button-Followers"
    case UserSheetMoreButtonLikers = "User-Sheet-More-Button-Likers"
    case TimelineSheetMoreButtonFollowers = "Timeline-Sheet-More-Button-Followers"
    case TimelineSheetMoreButtonLikers = "Timeline-Sheet-More-Button-Likers"

    // MARK: - 1.0.81
    case Followers = "Followers"
    case Likes = "Likes"
    case DraftAlertPickTimelineTitle = "Draft-Alert-PickTimeline-Title"
    case DraftAlertPickTimelineMessage = "Draft-Alert-PickTimeline-Message"
    case DraftAlertPickTimelineCancel = "Draft-Alert-PickTimeline-Cancel"

    // MARK: - 91
    case DraftAlertConfirmUploadTitle1s = "Draft-Alert-ConfirmUpload-Title:%@"
    case DraftAlertConfirmUploadMessage = "Draft-Alert-ConfirmUpload-Message"
    case DraftAlertConfirmUploadUpload = "Draft-Alert-ConfirmUpload-Upload"
    case DraftAlertConfirmUploadCancel = "Draft-Alert-ConfirmUpload-Cancel"
    
    // MARK: - 92
    case CreateGroupTimelineTitle = "User-Create-Group-Timeline-Title"
    case CreateGroupTimelineMessage = "User-Create-Group-Timeline-Message"
    case CreateSingleTimelineMessage = "User-Create-Single-Timeline-Message"
    case CreateGroupTimelineCancel = "User-Create-Group-Timeline-Cancel"
    case CreateTimelineAlertMessage = "User-Create-Timeline-AlertMessage"
    
    // MARK: - 93
    case ShowGroupTimelineTitle = "Show-Group-Timeline-Title"
    case ShowLeaveGroupTimelineMessage = "Show-Leave-Group-Timeline-Message"
    case ShowViewMembersGroupTimelineMessage = "Show-View-Members-Group-Timeline-Message"
    case ShowGroupTimelineCancel = "Show-Group-Timeline-Cancel"
    case ShowTimelineAlertMessage = "Show-Timeline-AlertMessage"

    

    var localized: String {
        get {
            return NSLocalizedString(rawValue, comment: rawValue)
        }
    }
    
}

func local(localizedString: LocalizedString) -> String {
    return localizedString.localized
}

func lformat(localizedString: LocalizedString, _ value: Int) -> String {
    return String(format: localizedString.localized, arguments: [value.description])
}

func lformat(localizedString: LocalizedString, _ value: CustomStringConvertible) -> String {
    return String(format: localizedString.localized, arguments: [value.description])
}

func lformat(localizedString: LocalizedString, _ value: String) -> String {
    return String(format: localizedString.localized, arguments: [value])
}

func lformat(localizedString: LocalizedString, args: CVarArgType...) -> String {
    return NSString(format: localizedString.localized, arguments: getVaList(args)) as String
}
