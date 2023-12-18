//
//  Log.swift
//  Tauch
//
//  Created by Apple on 2023/10/25.
//

import Foundation

import Adjust
import FirebaseAnalytics
import FirebaseFirestore

struct Log {

    static func event(name: String, logEventData: [String : Any] = [:]) {

        guard let currentUID = GlobalVar.shared.currentUID else { return }

        Task {

            let createdAt = Timestamp()
            var logEventDataExtension = logEventData
            logEventDataExtension.updateValue(currentUID, forKey: "uid")
            logEventDataExtension.updateValue(createdAt, forKey: "created_at")

            // print("logEvent name: \(name), logEventDataExtension : \(logEventDataExtension)")
            
            if let analyticsEvent = AnalyticsEvent(rawValue: name) {

                let eventName = analyticsEvent.rawValue

                let adjustToken = adjustEventToken(name: eventName)
                let event = ADJEvent(eventToken: adjustToken)

                // print("analytics event name: \(eventName),  adjust event token: \(adjustToken)")
                // Analytics イベント
                Analytics.setUserID(currentUID)
                Analytics.logEvent(eventName, parameters: logEventDataExtension)
                // Adjust イベント
                let createdAtDate = createdAt.dateValue().formatted()
                event?.addCallbackParameter("uid", value: currentUID)
                event?.addCallbackParameter("created_at", value: createdAtDate)
                Adjust.trackEvent(event)
            }
        }
    }

    static func adjustEventToken(name: String) -> String {

        var token = ""

        switch name {

        case "launch": token = "65tmlb"; break
        case "scene": token = "oiivpy"; break
        case "logout": token = "ga2me4"; break
        case "login": token = "kom6rz"; break

        case "sendSMSCode": token = "ri33ws"; break
        case "resendSMSCode": token = "g5wfhu"; break

        case "approachTutorial": token = "7yc6ne"; break
        case "messageTutorial": token = "uok9pi"; break
        case "invitationTutorial": token = "r4rjh5"; break
        case "phoneTutorial": token = "w2oya9"; break

        case "openNotificationSetting": token = "mxgv0y"; break
        case "openPushNotification": token = "u5kh3j"; break

        case "openHelpURL": token = "vk88n4"; break
        case "openBugReportURL": token = "8uahhv"; break
        case "openOpinionsAndRequestsURL": token = "p5axd1"; break
        case "openTermsOfServiceURL": token = "5nnuv0"; break
        case "openPrivacyPolicyURL": token = "2jyeh7"; break
        case "openSafetyAndSecurityGuidelinesURL": token = "53qpgs"; break
        case "openSpecialCommercialLawURL": token = "vimq7y"; break

        case "showMessageRoomNavigationProfile": token = "ggeum1"; break

        case "reloadSearchUserList": token = "ndx1fp"; break
        case "filterApproachCardList": token = "nko7f3"; break
        case "filterInvitationList": token = "ts0zms"; break

        case "approachMatch": token = "7fb8yc"; break
        case "approachNG": token = "kvj7kg"; break

        case "clickApproachGood": token = "1o6e15"; break
        case "swipeApproachGood": token = "1gspz0"; break
        case "clickApproachSkip": token = "iy1nx0"; break
        case "swipeApproachSkip": token = "fggp5a"; break
        case "clickApproachMatch": token = "1h18xf"; break
        case "swipeApproachMatch": token = "r3yr41"; break
        case "clickApproachNG": token = "7opwqb"; break
        case "swipeApproachNG": token = "8jyzna"; break

        case "clickInvitationApplication": token = "nz6ur0"; break

        case "nextCardProfileSubImg": token = "rnpzsu"; break
        case "prevCardProfileSubImg": token = "823p07"; break

        case "selectNewMatchRoom": token = "h24e80"; break
        case "selectMessageRoom": token = "fkejf4"; break

        case "showMessageRoomReportAlert": token = "pty4cj"; break
        case "showAvatarProfile": token = "q92iho"; break
        case "sendMessageFromTalkView": token = "lfy0qx"; break
        case "sendMessageFromPhotoLibraryInput": token = "r536kp"; break
        case "sendMessageFromCameraInput": token = "o0xj6h"; break
        case "sendMessageFromMessageInput": token = "xe20iu"; break
        case "openMessageLinkURL": token = "ss1t5b"; break

        case "messageImageZoom": token = "rn0z01"; break
        case "messageImageSave": token = "2ppcah"; break

        case "profilePreview": token = "skh7ny"; break
        case "profileDetail": token = "6ra396"; break
        case "nextProfileDetailSubImg": token = "aoeboc"; break
        case "nextProfilePreviewSubImg": token = "p2j26n"; break
        case "prevProfileDetailSubImg": token = "m0mvvw"; break
        case "prevProfilePreviewSubImg": token = "gjg7yr"; break

        case "pickupExampleIntroduce": token = "i7xbfx"; break
        case "selectExampleIntroduce": token = "w0o0w3"; break

        case "messageNotification": token = "pzi3ta"; break
        case "blockNotification": token = "rmibuj"; break
        case "violationNotification": token = "c64c6n"; break
        case "stopNotification": token = "jp7e8t"; break
        case "withdrawalNotification": token = "fl24l5"; break
        case "approachNotification": token = "c5qagg"; break
        case "approachMatchNotification": token = "7dmubd"; break
        case "invitationApplicationNotification": token = "5p749p"; break
        case "invitationMatchNotification": token = "3ikk0z"; break
        case "boardSendMessageNotification": token = "sw3pg6"; break
        case "visitorNotification": token = "s2xo4u"; break

        case "approachMatchCreateRoom": token = "acnmy6"; break
        case "approachMatchMessage": token = "gly23i"; break

        case "profileCreate": token = "mf1m0i"; break

        case "appReview": token = "1akbej"; break

        case "uploadBoardImg": token = "jw3dgo"; break
        case "reloadBoard": token = "yyr6zi"; break
        case "boardCreateRoom": token = "akuopp"; break
        case "boardMessage": token = "h772zc"; break

        case "uploadHobbyCardCategoryImg": token = "jnwt9g"; break
        case "changeLikeCard": token = "95nrf0"; break

        case "reloadInvitationList": token = "qddw3x"; break
        case "alertInvitationDelete": token = "no39m9"; break
        case "invitationMatchMessage": token = "q6bm19"; break
        case "invitationApplicationOK": token = "g2x99a"; break
        case "invitationApplicationNG": token = "29cd1w"; break
        case "invitationMatchCreateRoom": token = "xrblx0"; break

        case "reloadMessageList": token = "x1muag"; break
        case "removeMessageRoom": token = "fgeau3"; break

        case "restModeCancel": token = "v6vd0r"; break
        case "restModeValid": token = "vn8mty"; break

        case "uploadIdentificationImg": token = "w5v38z"; break
        case "changeNotificationSetting": token = "urhc1l"; break

        case "violation": token = "9xyn50"; break
        case "block": token = "i7frvo"; break
        case "stop": token = "6shhi1"; break
        case "withdrawal": token = "hhazq3"; break

        case "approachGood": token = "nsglyq"; break
        case "approachSkip": token = "v8sklg"; break

        case "boardMatch": token = "oarveb"; break

        case "invitationCreate": token = "3gf0rw"; break
        case "invitationEdit": token = "gxeiaz"; break
        case "invitationDelete": token = "4rk7dh"; break
        case "invitationApplication": token = "3nss2m"; break

        case "makeVisitor": token = "tghlcq"; break

        case "boardDelete": token = "bnxqwp"; break
        case "changeProfileHobbies": token = "xhdivh"; break

        default: break
        }

        return token
    }
}


enum AdjustEvent: String {

    case launch = "65tmlb"
    case scene = "oiivpy"
    case logout = "ga2me4"
    case login = "kom6rz"

    case sendSMSCode = "ri33ws"
    case resendSMSCode = "g5wfhu"

    case approachTutorial = "7yc6ne"
    case messageTutorial = "uok9pi"
    case invitationTutorial = "r4rjh5"
    case phoneTutorial = "w2oya9"

    case openNotificationSetting = "mxgv0y"
    case openPushNotification = "u5kh3j"

    case openHelpURL = "vk88n4"
    case openBugReportURL = "8uahhv"
    case openOpinionsAndRequestsURL = "p5axd1"
    case openTermsOfServiceURL = "5nnuv0"
    case openPrivacyPolicyURL = "2jyeh7"
    case openSafetyAndSecurityGuidelinesURL = "53qpgs"
    case openSpecialCommercialLawURL = "vimq7y"

    case showMessageRoomNavigationProfile = "ggeum1"

    case reloadSearchUserList = "ndx1fp"
    case filterApproachCardList = "nko7f3"
    case filterInvitationList = "ts0zms"

    case approachMatch = "7fb8yc"
    case approachNG = "kvj7kg"

    case clickApproachGood = "1o6e15"
    case swipeApproachGood = "1gspz0"
    case clickApproachSkip = "iy1nx0"
    case swipeApproachSkip = "fggp5a"
    case clickApproachMatch = "1h18xf"
    case swipeApproachMatch = "r3yr41"
    case clickApproachNG = "7opwqb"
    case swipeApproachNG = "8jyzna"

    case clickInvitationApplication = "nz6ur0"

    case nextCardProfileSubImg = "rnpzsu"
    case prevCardProfileSubImg = "823p07"

    case selectNewMatchRoom = "h24e80"
    case selectMessageRoom = "fkejf4"

    case showMessageRoomReportAlert = "pty4cj"
    case showAvatarProfile = "q92iho"
    case sendMessageFromTalkView = "lfy0qx"
    case sendMessageFromPhotoLibraryInput = "r536kp"
    case sendMessageFromCameraInput = "o0xj6h"
    case sendMessageFromMessageInput = "xe20iu"
    case openMessageLinkURL = "ss1t5b"

    case messageImageZoom = "rn0z01"
    case messageImageSave = "2ppcah"

    case profilePreview = "skh7ny"
    case profileDetail = "6ra396"
    case nextProfileDetailSubImg = "aoeboc"
    case nextProfilePreviewSubImg = "p2j26n"
    case prevProfileDetailSubImg = "m0mvvw"
    case prevProfilePreviewSubImg = "gjg7yr"

    case pickupExampleIntroduce = "i7xbfx"
    case selectExampleIntroduce = "w0o0w3"

    case messageNotification = "pzi3ta"
    case blockNotification = "rmibuj"
    case violationNotification = "c64c6n"
    case stopNotification = "jp7e8t"
    case withdrawalNotification = "fl24l5"
    case approachNotification = "c5qagg"
    case approachMatchNotification = "7dmubd"
    case invitationApplicationNotification = "5p749p"
    case invitationMatchNotification = "3ikk0z"
    case boardSendMessageNotification = "sw3pg6"
    case visitorNotification = "s2xo4u"

    case approachMatchCreateRoom = "acnmy6"
    case approachMatchMessage = "gly23i"

    case profileCreate = "mf1m0i"

    case appReview = "1akbej"

    case uploadBoardImg = "jw3dgo"
    case reloadBoard = "yyr6zi"
    case boardCreateRoom = "akuopp"
    case boardMessage = "h772zc"

    case uploadHobbyCardCategoryImg = "jnwt9g"
    case changeLikeCard = "95nrf0"

    case reloadInvitationList = "qddw3x"
    case alertInvitationDelete = "no39m9"
    case invitationMatchMessage = "q6bm19"
    case invitationApplicationOK = "g2x99a"
    case invitationApplicationNG = "29cd1w"
    case invitationMatchCreateRoom = "xrblx0"

    case reloadMessageList = "x1muag"
    case removeMessageRoom = "fgeau3"

    case restModeCancel = "v6vd0r"
    case restModeValid = "vn8mty"

    case uploadIdentificationImg = "w5v38z"
    case changeNotificationSetting = "urhc1l"

    case violation = "9xyn50"
    case block = "i7frvo"
    case stop = "6shhi1"
    case withdrawal = "hhazq3"
    case approachGood = "nsglyq"
    case approachSkip = "v8sklg"
    case boardMatch = "oarveb"
    case invitationCreate = "3gf0rw"
    case invitationEdit = "gxeiaz"
    case invitationDelete = "4rk7dh"
    case invitationApplication = "3nss2m"
    case makeVisitor = "tghlcq"
    case boardDelete = "bnxqwp"
    case changeProfileHobbies = "xhdivh"
}

enum AnalyticsEvent: String {

    case launch
    case scene
    case logout
    case login
    case sendSMSCode
    case resendSMSCode

    case approachTutorial
    case messageTutorial
    case invitationTutorial
    case phoneTutorial

    case openNotificationSetting
    case openPushNotification

    case openHelpURL
    case openBugReportURL
    case openOpinionsAndRequestsURL
    case openTermsOfServiceURL
    case openPrivacyPolicyURL
    case openSafetyAndSecurityGuidelinesURL
    case openSpecialCommercialLawURL

    case showMessageRoomNavigationProfile

    case reloadSearchUserList
    case filterApproachCardList
    case filterInvitationList

    case approachMatch
    case approachNG

    case clickApproachGood
    case swipeApproachGood
    case clickApproachSkip
    case swipeApproachSkip
    case clickApproachMatch
    case swipeApproachMatch
    case clickApproachNG
    case swipeApproachNG

    case clickInvitationApplication

    case nextCardProfileSubImg
    case prevCardProfileSubImg

    case selectNewMatchRoom
    case selectMessageRoom

    case showMessageRoomReportAlert
    case showAvatarProfile
    case sendMessageFromTalkView
    case sendMessageFromPhotoLibraryInput
    case sendMessageFromCameraInput
    case sendMessageFromMessageInput
    case openMessageLinkURL

    case messageImageZoom
    case messageImageSave

    case profilePreview
    case profileDetail
    case nextProfileDetailSubImg
    case nextProfilePreviewSubImg
    case prevProfileDetailSubImg
    case prevProfilePreviewSubImg

    case pickupExampleIntroduce

    case messageNotification
    case blockNotification
    case violationNotification
    case stopNotification
    case withdrawalNotification
    case approachNotification
    case approachMatchNotification
    case invitationApplicationNotification
    case invitationMatchNotification
    case boardSendMessageNotification
    case visitorNotification

    case approachMatchCreateRoom
    case approachMatchMessage

    case selectExampleIntroduce

    case profileCreate

    case appReview

    case uploadBoardImg
    case reloadBoard
    case boardCreateRoom
    case boardMessage

    case uploadHobbyCardCategoryImg
    case changeLikeCard

    case reloadInvitationList
    case alertInvitationDelete
    case invitationMatchMessage
    case invitationApplicationOK
    case invitationApplicationNG
    case invitationMatchCreateRoom

    case reloadMessageList
    case removeMessageRoom

    case restModeCancel
    case restModeValid

    case uploadIdentificationImg
    case changeNotificationSetting

    case violation
    case block
    case stop
    case withdrawal
    case approachGood
    case approachSkip
    case boardMatch
    case invitationCreate
    case invitationEdit
    case invitationDelete
    case invitationApplication
    case makeVisitor
    case boardDelete
    case changeProfileHobbies
}
