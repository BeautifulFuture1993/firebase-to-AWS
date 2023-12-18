//
//  AppDelegate.swift
//  Tatibanashi-MVP
//
//  Created by Apple on 2022/05/03.
//

import UIKit
import SDWebImage
import AudioToolbox
import CallKit
import PushKit
import FBSDKCoreKit
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import FirebaseAnalytics
import UserNotifications
import Typesense
import Adjust
import TikTokOpenSDKCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    private var ConversionData: [AnyHashable: Any]? = nil
    private let viewController = UIViewController()
    private let userDefaults = UserDefaults.standard
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
<<<<<<< HEAD
        // Firebaseの初期化
        FirebaseApp.configure()
        // delegateを設定
        UNUserNotificationCenter.current().delegate = self
        // Firebase Messageを設定
        Messaging.messaging().delegate = self
        // PushKitを設定
        voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
        // Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // 趣味カードの事前取得
        // viewController.fetchHobbyCardInfoFromTypesense()
        // アプリ初回立ち上げ時のみ実行
        if UserDefaults.standard.object(forKey: "launchedTimes") == nil { viewController.logoutAction() }
=======
        FirebaseApp.configure() // Firebaseの初期化
        UNUserNotificationCenter.current().delegate = self // delegateを設定
        Messaging.messaging().delegate = self // Firebase Messageを設定
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions) // Facebook
        // Adjust設定
        let adjustConfig = ADJConfig(
            appToken: "kmtwwz4qvabk",
            environment: ADJEnvironmentProduction
        )
        // adjustConfig?.logLevel = ADJLogLevelVerbose
        Adjust.appDidLaunch(adjustConfig)
        // アプリ初回立ち上げ時のみ実行
        if userDefaults.object(forKey: "launchedTimes") == nil {
            viewController.logoutAction()
        }
        
        // 立ち上げ時に趣味カードを取得
        fetchHobbyCardInfoFromFirestore()
        
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
        //アプリ起動回数を記録
        let launchedTimes = userDefaults.object(forKey: "launchedTimes") as? Int ?? 0
        userDefaults.set(launchedTimes + 1, forKey: "launchedTimes")
        
        // アプリがアップデートされた場合
        if isVersionUpdated() {
            print("アプリがアップデートされました！")
            userDefaults.set(true, forKey: "app_version_updated")
        }
        
        // アプリのバージョンを保存
        backupLaunchAppVersion()
        
        // キャッシュを一週間で削除
        SDImageCache.shared.config.maxDiskAge = 60 * 60 * 24 * 7
        
        // 起動ログ
        Log.event(name: "launch")
        return true
    }
    
    // Facebook・Tiktok
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookSDK = ApplicationDelegate.shared.application(app, open: url, options: options)
        let tiktokSDK = TikTokURLHandler.handleOpenURL(url)
        let activeSDK = (facebookSDK || tiktokSDK)
        return activeSDK
    }
    
    // Tiktok openURL
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let tiktokURLHandle = (TikTokURLHandler.handleOpenURL(userActivity.webpageURL))
        return tiktokURLHandle
    }
    
    // デバイストークンが取得が失敗した際に呼び出されるメソッド
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("リモート通知に登録できません: \(error.localizedDescription)")
    }
    
    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // APNsトークンをFCMに渡す(FCM Tokenが返却される)
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()
        
        print("Your device token for PushNotification:", token)
    }
    
    // SceneDelegateにつなげるAppDelegateメソッド
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //　アプリ起動中にプッシュ通知のペイロードを取得
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // 画面がアクティブではない場合のみバッジを更新する
        let applicationState = UIApplication.shared.applicationState
        if applicationState != .active && applicationState != .inactive {
            
            UIApplication.shared.applicationIconBadgeNumber += 1
            
            if let notificationCategory = userInfo["gcm.notification.category"] as? String {
                // メッセージ通知の時のみ更新
                if notificationCategory == "6" {
                    let messageBadgeNumber = UserDefaults.standard.integer(forKey: "applicationIconMessageBadgeNumber")
                    UserDefaults.standard.set(messageBadgeNumber + 1, forKey: "applicationIconMessageBadgeNumber")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        print(userInfo)
        
        completionHandler(.newData)
    }
    
    // バイブレーション通知メソッド
    func vibrationNotification(userInfo: [AnyHashable: Any]) {
        // アプリ内バイブレーションをONにする
        let isVibrationNotification = userInfo["is_vibration_notification"] as? String
        // バイブレーション通知がONの場合
        if isVibrationNotification == "true" {
            // 通知バイブ
            var soundIdRing:SystemSoundID = 1005
            if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil){
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    // fcmToken受信時に呼ばれるハンドラー (トークン更新のモニタリング)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),object: nil,userInfo: dataDict)
        
        UserDefaults.standard.set(fcmToken, forKey: "FCM_TOKEN")
        UserDefaults.standard.synchronize()
    }
}

/** 趣味カード関連の処理 **/
extension AppDelegate {
    // 趣味カード情報の取得
    func fetchHobbyCardInfoFromFirestore() {
        let db = Firestore.firestore()
        // 趣味カードの監視
        db.collection("hobby_cards").getDocuments { [weak self] (querySnapshot, err) in
            guard let _ = self else { return }
            if let err = err { print("趣味カード情報の取得失敗: \(err)"); return }
            guard let documents = querySnapshot?.documents else { return }
            print("事前取得趣味カードドキュメント数 : \(documents.count)")
            let hobbyCards = documents.map({ HobbyCard(document: $0) })
            GlobalVar.shared.globalHobbyCards = hobbyCards
        }
    }
}

// Appのバージョンを管理
extension AppDelegate {
    
    private func getCurrentAppVersion() -> String {
        let bundle = Bundle.main
        let versionKey = "CFBundleShortVersionString"
        let versiton = bundle.object(forInfoDictionaryKey: versionKey) as? String ?? "unknown"
        
        return versiton
    }
    
    private func backupLaunchAppVersion() {
        let version = getCurrentAppVersion()
        userDefaults.set(version, forKey: "backup_launch_app_version")
    }
    
    private func isVersionUpdated() -> Bool {
        let launchedTimes = userDefaults.integer(forKey: "launchedTimes")
        let backupVersion = userDefaults.string(forKey: "backup_launch_app_version") ?? "unknown"
        let currentVersion = getCurrentAppVersion()
        
        print("前回起動時のAppバージョン:", backupVersion)
        print("現在のAppバージョン:", currentVersion)
        
        if backupVersion == "unknown" {
            if launchedTimes == 1 {
                print("新規ユーザー")
                userDefaults.set(true, forKey: "after_new_terms_user")
                return false
            }
            
            return true
        }
        
        return backupVersion != currentVersion
    }
}

// ----- 通話機能をRoom型に変更したので一旦コメントアウト -----
// PushKit関連
//extension AppDelegate: PKPushRegistryDelegate {
//
//    private func setUpVoIP() {
//        let voipRegistry = PKPushRegistry(queue: .main)
//        voipRegistry.delegate = self
//        voipRegistry.desiredPushTypes = [.voIP]
//    }
//
//    // VoIP通知の受信情報を更新
//    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//        Messaging.messaging().apnsToken = pushCredentials.token
//
//        let deviceToken = pushCredentials.token.map {
//            String(format: "%02.2hhx", $0)
//        }.joined()
//
//        print("Your device token for VoIP:", deviceToken)
//
//        let dataDict: [String: String] = ["token": deviceToken]
//        NotificationCenter.default.post(name: Notification.Name("DeviceToken"),object: nil,userInfo: dataDict)
//
//        UserDefaults.standard.set(deviceToken, forKey: "DEVICE_TOKEN")
//        UserDefaults.standard.synchronize()
//    }
//
//    // VoIP通知受信
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
//        guard type == .voIP else  {
//            return
//        }
//
//        let payload = payload.dictionaryPayload
//        guard let partnerName = payload["nickName"] as? String,
//            let partnerImageUrl = payload["profileIconImg"] as? String,
//            let skywayToken = payload["skywayToken"] as? String,
//            let roomName = payload["roomName"] as? String
//        else {
//            return
//        }
//
//        self.callViewController = CallViewController()
//        self.partnerName = partnerName
//        self.partnerImageUrl = partnerImageUrl
//        self.partnerImage.setImage(withURLString: partnerImageUrl)
//        self.skywayToken = skywayToken
//        self.roomName = roomName
//
//        callManager.setUp(self)
//        callManager.partnerName = partnerName
//        callManager.incomingCall()
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(endIncomingCall),
//            name: NSNotification.Name(NotificationName.EndIncomingCall.rawValue),
//            object: nil
//        )
//
//        let task = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//        UIApplication.shared.endBackgroundTask(task)
//    }
//
//    // VoIP通知無効
//    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
//        print("invalidate push token")
//    }
//}

// ----- 通話機能をRoom型に変更したので一旦コメントアウト -----
// CallKit関連
//extension AppDelegate: CXProviderDelegate {
//
//    func providerDidReset(_ provider: CXProvider) {}
//
//    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//        callManager.ConfigureAudioSession()
//        callManager.connected()
//
//        guard let callViewController = callViewController else {
//            return
//        }
//
//        callViewController.partnerName = partnerName
//        callViewController.iconImage = partnerImage.image
//        callViewController.skywayToken = skywayToken
//        callViewController.roomName = roomName
//        callViewController.modalTransitionStyle = .crossDissolve
//        callViewController.modalPresentationStyle = .fullScreen
//
//        let rootViewController = getRootViewController()
//
//        rootViewController?.present(callViewController, animated: true) {
//            if self.callManager.isIncomingCallSuccess {
//                action.fulfill()
//            } else {
//                let alert = UIAlertController(title: "失敗", message: "通話の応答に失敗しました。\n時間をおいて再度やり直してください。", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "はい", style: .default) { _ in
//                    callViewController.dismiss(animated: true)
//                    action.fail()
//                }
//                alert.addAction(ok)
//                callViewController.present(alert, animated: true)
//            }
//        }
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//        if callManager.isEndCallSuccess {
//            callViewController?.dismiss(animated: true)
//            callViewController = nil
//            action.fulfill()
//        } else {
//            callViewController?.dismiss(animated: true)
//            callViewController = nil
//            action.fail()
//        }
//    }
//
//    @objc private func endIncomingCall() {
//        callManager.endCall()
//    }
//}

// グローバル変数 (シングルトン)
class GlobalVar {
    
    private init() {}
    static var shared = GlobalVar()
    
    func reInit() {
        let globalHobbies = GlobalVar.shared.globalHobbyCards
        GlobalVar.shared = GlobalVar()
        GlobalVar.shared.globalHobbyCards = globalHobbies
    }
    
    var window: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first
    }
    // ログインユーザ, ルームのデータを毎回DBから取得させないように共通の変数として宣言
    var loginUser: User?
    #if PROD // 本番環境
    let adminUID = "kwHlQEffmMMoDvvzaafSDXdf6qp2"
    let bundleID = "com.couloge.tatibanashi.mvp.Tauch"
    #elseif DEV // 検証環境
    let adminUID = "Um19jBHw9PVmKppVdhjU1ysWwOG3"
    let bundleID = "com.couloge.tatibanashi.mvp"
    #endif
    var currentUID: String?
    var thisClassName: String?
    var historyClassName = [String]()
    var backgroundClassName = [String]()
    // 現住所一覧
    let areas = [
        "東京都", "千葉県", "埼玉県", "神奈川県", "北海道",
        "青森県", "岩手県", "宮城県", "秋田県", "山形県",
        "福島県", "茨城県", "栃木県", "群馬県", "新潟県",
        "富山県", "石川県", "福井県", "山梨県", "長野県",
        "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県",
        "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
        "鳥取県", "島根県", "岡山県", "広島県", "山口県",
        "徳島県", "香川県", "愛媛県", "高知県", "福岡県",
        "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県",
        "鹿児島県", "沖縄県"
    ]
    let municipalities = [
        "北海道": ["札幌市", "函館市", "小樽市", "室蘭市", "旭川市", "釧路市", "帯広市", "北見市", "夕張市", "岩見沢市", "網走市", "留萌市", "苫小牧市", "稚内市", "美唄市", "芦別市", "江別市", "赤平市", "紋別市", "士別市", "名寄市", "三笠市", "根室市", "千歳市", "滝川市", "砂川市", "歌志内市", "深川市", "富良野市", "登別市", "恵庭市", "伊達市", "北広島市", "石狩市", "北斗市"],
        "青森県": ["青森市", "弘前市", "八戸市", "五所川原市", "十和田市", "三沢市", "むつ市", "つがる市", "平川市", "黒石市"],
        "岩手県": ["盛岡市", "宮古市", "大船渡市", "花巻市", "釜石市", "一関市", "北上市", "久慈市", "遠野市", "陸前高田市", "二戸市", "八幡平市", "奥州市", "滝沢市"],
        "宮城県": ["仙台市", "石巻市", "塩竈市", "気仙沼市", "白石市", "名取市", "角田市", "多賀城市", "岩沼市", "登米市", "栗原市", "東松島市", "大崎市", "富谷市"],
        "秋田県": ["秋田市", "能代市", "大館市", "横手市", "男鹿市", "湯沢市", "鹿角市", "由利本荘市", "潟上市", "大仙市", "北秋田市", "仙北市", "にかほ市"],
        "山形県": ["山形市", "米沢市", "鶴岡市", "酒田市", "新庄市", "寒河江市", "上山市", "村山市", "長井市", "天童市", "東根市", "尾花沢市", "南陽市"],
        "福島県": ["会津若松市", "福島市", "郡山市", "白河市", "須賀川市", "喜多方市", "相馬市", "二本松市", "いわき市", "田村市", "南相馬市", "伊達市", "本宮市"],
        "茨城県": ["水戸市", "日立市", "土浦市", "古河市", "石岡市", "結城市", "龍ケ崎市", "下妻市", "常陸太田市", "常総市", "高萩市", "北茨城市", "笠間市", "取手市", "牛久市", "つくば市", "ひたちなか市", "鹿島市", "潮来市", "守谷市", "常陸大宮市", "那珂市", "筑西市", "坂東市", "稲敷市", "かすみがうら市", "神栖市", "行方市", "桜川市", "鉾田市", "つくばみらい市", "小美玉市"],
        "栃木県": ["宇都宮市", "足利市", "栃木市", "佐野市", "鹿沼市", "日光市", "小山市", "真岡市", "大田原市", "矢板市", "那須塩原市", "さくら市", "那須烏山市", "下野市"],
        "群馬県": ["前橋市", "高崎市", "桐生市", "伊勢崎市", "太田市", "沼田市", "館林市", "渋川市", "藤岡市", "富岡市", "安中市", "みどり市"],
        "埼玉県": ["川越市", "熊谷市", "川口市", "行田市", "秩父市", "所沢市", "飯能市", "加須市", "本庄市", "東松山市", "春日部市", "狭山市", "羽生市", "鴻巣市", "深谷市", "上尾市", "草加市", "越谷市", "蕨市", "戸田市", "入間市", "朝霞市", "志木市", "和光市", "新座市", "桶川市", "久喜市", "北本市", "八潮市", "富士見市", "三郷市", "蓮田市", "坂戸市", "幸手市", "鶴ヶ島市", "日高市", "吉川市", "さいたま市", "ふじみ野市", "白岡市"],
        "千葉県": ["千葉市", "銚子市", "市川市", "船橋市", "館山市", "木更津市", "松戸市", "野田市", "茂原市", "成田市", "佐倉市", "東金市", "旭市", "習志野市", "柏市", "勝浦市", "市原市", "流山市", "八千代市", "我孫子市", "鴨川市", "鎌ヶ谷市", "君津市", "富津市", "浦安市", "四街道市", "袖ヶ浦市", "八街市", "印西市", "白井市", "富里市", "いすみ市", "匝瑳市", "南房総市", "香取市", "山武市", "大網白里市"],
        "東京都": ["足立区", "荒川区", "板橋区", "江戸川区", "大田区", "葛飾区", "北区", "江東区", "品川区", "渋谷区", "新宿区", "杉並区", "墨田区", "世田谷区", "台東区", "千代田区", "中央区", "豊島区", "中野区", "練馬区", "文京区", "港区", "目黒区", "八王子市", "立川市", "武蔵野市", "三鷹市", "青梅市", "府中市", "昭島市", "調布市", "町田市", "小金井市", "小平市", "日野市", "東村山市", "国分寺市", "国立市", "福生市", "狛江市", "東大和市", "清瀬市", "東久留米市", "武蔵村山市", "多摩市", "稲城市", "羽村市", "あきる野市", "西東京市", "小笠原村"],
        "神奈川県": ["横浜市", "横須賀市", "川崎市", "平塚市", "鎌倉市", "藤沢市", "小田原市", "茅ヶ崎市", "逗子市", "相模原市", "三浦市", "秦野市", "厚木市", "大和市", "伊勢原市", "海老名市", "座間市", "南足柄市", "綾瀬市"],
        "新潟県": ["新潟市", "長岡市", "小千谷市", "三条市", "柏崎市", "新発田市", "加茂市", "十日町市", "見附市", "村上市", "燕市", "糸魚川市", "妙高市", "五泉市", "上越市", "佐渡市", "阿賀野市", "魚沼市", "南魚沼市", "胎内市"],
        "富山県": ["富山市", "高岡市", "魚津市", "氷見市", "滑川市", "黒部市", "砺波市", "小矢部市", "南砺市", "射水市"],
        "石川県": ["金沢市", "七尾市", "小松市", "輪島市", "珠洲市", "加賀市", "羽咋市", "かほく市", "白山市", "能美市", "野々市市"],
        "福井県": ["福井市", "敦賀市", "小浜市", "大野市", "勝山市", "鯖江市", "あわら市", "越前市", "坂井市"],
        "山梨県": ["甲府市", "富士吉田市", "都留市", "山梨市", "大月市", "韮崎市", "南アルプス市", "甲斐市", "笛吹市", "北杜市", "上野原市", "甲州市", "中央市"],
        "長野県": ["長野市", "松本市", "上田市", "岡谷市", "飯田市", "諏訪市", "須坂市", "小諸市", "伊那市", "中野市", "駒ヶ根市", "大町市", "飯山市", "茅野市", "塩尻市", "佐久市", "千曲市", "東御市", "安曇野市"],
        "岐阜県": ["岐阜市", "大垣市", "高山市", "多治見市", "関市", "中津川市", "羽島市", "美濃市", "美濃加茂市", "瑞浪市", "恵那市", "土岐市", "各務原市", "可児市", "山県市", "瑞穂市", "飛騨市", "本巣市", "郡上市", "下呂市", "海津市"],
        "静岡県": ["静岡市", "浜松市", "沼津市", "熱海市", "三島市", "富士宮市", "伊藤市", "島田市", "磐田市", "焼津市", "藤枝市", "掛川市", "富士市", "御殿場市", "袋井市", "裾野市", "下田市", "湖西市", "伊豆市", "御前崎市", "菊川市", "伊豆の国市", "牧之原市"],
        "愛知県": ["名古屋市", "豊橋市", "岡崎市", "一宮市", "瀬戸市", "半田市", "春日井市", "豊川市", "津島市", "碧南市", "刈谷市", "豊田市", "安城市", "西尾市", "常滑市", "犬山市", "蒲郡市", "江南市", "小牧市", "稲沢市", "新城市", "東海市", "大府市", "知多市", "知立市", "尾張旭市", "高浜市", "岩倉市", "豊明市", "日進市", "田原市", "愛西市", "清須市", "北名古屋市", "弥富市", "みよし市", "あま市", "長久手市"],
        "三重県": ["津市", "四日市市", "伊勢市", "松阪市", "桑名市", "鈴鹿市", "名張市", "尾鷲市", "亀山市", "鳥羽市", "熊野市", "いなべ市", "志摩市", "伊賀市"],
        "滋賀県": ["大津市", "彦根市", "長浜市", "近江八幡市", "草津市", "守山市", "栗東市", "甲賀市", "野洲市", "湖南市", "高島市", "東近江市", "米原市"],
        "京都府": ["京都市", "福知山市", "舞鶴市", "綾部市", "宇治市", "宮津市", "亀岡市", "城陽市", "長岡京市", "向日市", "八幡市", "京田辺市", "京丹後市", "南丹市", "木津川市"],
        "大阪府": ["大阪市", "堺市", "岸和田市", "豊中市", "池田市", "吹田市", "泉大津市", "高槻市", "貝塚市", "守口市", "枚方市", "茨木市", "八尾市", "泉佐野市", "富田林市", "寝屋川市", "河内長野市", "松原市", "大東市", "和泉市", "箕面市", "柏原市", "羽曳野市", "門真市", "摂津市", "高石市", "藤井寺市", "東大阪市", "泉南市", "四條畷市", "交野市", "大阪狭山市", "阪南市"],
        "兵庫県": ["神戸市", "姫路市", "尼崎市", "明石市", "西宮市", "洲本市", "芦屋市", "伊丹市", "相生市", "豊岡市", "加古川市", "赤穂市", "西脇市", "宝塚市", "三木市", "高砂市", "川西市", "小野市", "三田市", "加西市", "丹波篠山市", "養父市", "丹波市", "南あわじ市", "朝来市", "淡路市", "宍粟市", "たつの市", "加東市"],
        "奈良県": ["奈良市", "大和高田市", "大和郡山市", "天理市", "橿原市", "桜井市", "五條市", "御所市", "生駒市", "香芝市", "葛城市", "宇陀市"],
        "和歌山県": ["和歌山市", "海南市", "橋本市", "有田市", "御坊市", "田辺市", "新宮市", "紀の川市", "岩出市"],
        "鳥取県": ["鳥取市", "米子市", "倉吉市", "境港市"],
        "島根県": ["松江市", "浜田市", "出雲市", "益田市", "大田市", "安来市", "江津市", "雲南市"],
        "岡山県": ["岡山市", "倉敷市", "津山市", "玉野市", "笠岡市", "井原市", "総社市", "高梁市", "新見市", "備前市", "瀬戸内市", "赤岩市", "真庭市", "美作市", "浅口市"],
        "広島県": ["広島市", "尾道市", "呉市", "福山市", "三原市", "三次市", "府中市", "庄原市", "大竹市", "竹原市", "東広島市", "廿日市市", "安芸高田市", "江田島市"],
        "山口県": ["下関市", "宇部市", "山口市", "萩市", "防府市", "下松市", "岩国市", "光市", "美祢市", "長門市", "柳井市", "周南市", "山陽小野田市"],
        "徳島県": ["徳島市", "鳴門市", "小松島市", "阿南市", "吉野川市", "美馬市", "阿波市", "三好市"],
        "香川県": ["高松市", "丸亀市", "坂出市", "善通寺市", "観音寺市", "さぬき市", "東かがわ市", "三豊市"],
        "愛媛県": ["松山市", "今治市", "宇和島市", "八幡浜市", "新居浜市", "西条市", "大洲市", "伊予市", "四国中央市", "西予市", "東温市"],
        "高知県": ["高知市", "宿毛市", "安芸市", "土佐清水市", "須崎市", "土佐市", "室戸市", "南国市", "四万十市", "香南市", "香美市"],
        "福岡県": ["福岡市", "久留米市", "大牟田市", "直方市", "飯塚市", "田川市", "柳川市", "筑後市", "八女市", "大川市", "行橋市", "豊前市", "中間市", "北九州市", "小郡市", "筑紫野市", "春日市", "大野城市", "太宰府市", "宗像市", "古賀市", "福津市", "うきは市", "宮若市", "朝倉市", "嘉麻市", "みやま市", "糸島市", "那珂川市"],
        "佐賀県": ["佐賀市", "唐津市", "鹿島市", "伊万里市", "鳥栖市", "武雄市", "武雄市", "多久市", "小城市", "嬉野市", "神埼市"],
        "長崎県": ["長崎市", "佐世保市", "島原市", "諫早市", "大村市", "平戸市", "松浦市", "対馬市", "壱岐市", "五島市", "西海市", "雲仙市", "南島原市"],
        "熊本県": ["熊本市", "八代市", "人吉市", "荒尾市", "水俣市", "玉名市", "山鹿市", "菊池市", "宇土市", "上天草市", "宇城市", "阿蘇市", "合志市", "天草市"],
        "大分県": ["大分市", "別府市", "中津市", "日田市", "佐伯市", "臼杵市", "津久見市", "竹田市", "豊後高田市", "杵築市", "宇佐市", "豊後大野市", "由布市", "国東市"],
        "宮崎県": ["宮崎市", "都城市", "延岡市", "日南市", "小林市", "日向市", "串間市", "西都市", "えびの市"],
        "鹿児島県": ["鹿児島市", "鹿屋市", "枕崎市", "阿久根市", "指宿市", "出水市", "西之表市", "垂水市", "薩摩川内市", "日置市", "曽於市", "いちき串木野市", "霧島市", "南さつま市", "志布志市", "奄美市", "南九州市", "伊佐市", "姶良市"],
        "沖縄県": ["那覇市", "石垣市", "宜野湾市", "浦添市", "名護市", "糸満市", "沖縄市", "豊見城市", "うるま市", "宮古島市", "南城市"]
    ]
    // 募集カテゴリ一覧
    let invitationCategories = [
        "お笑い", "お酒", "アート", "カフェ", "ゲーム",
        "スポーツ", "レジャー", "映画", "演劇/舞台",
        "街歩き", "趣味", "音楽", "食事", "その他"
    ]
    let invitationCategoriesWithImg = [
        "お笑い": UIImage(named: "comedy"),
        "お酒": UIImage(named: "sake"),
        "アート": UIImage(named: "art"),
        "カフェ": UIImage(named: "cafe"),
        "ゲーム": UIImage(named: "game"),
        "スポーツ": UIImage(named: "sports"),
        "レジャー": UIImage(named: "leisure"),
        "映画": UIImage(named: "movie"),
        "演劇/舞台": UIImage(named: "theater"),
        "街歩き": UIImage(named: "walkingAroundCity"),
        "趣味": UIImage(named: "hobby"),
        "音楽": UIImage(named: "music"),
        "食事": UIImage(named: "meal"),
        "その他": UIImage(named: "friend")
    ] as! [String:UIImage]
    // 募集日程
    let invitationDays = ["月", "火", "水", "木", "金", "土", "日"]
    // リンク関連
    let links = [
        "help": "https://touch-web.link/help/",
        "bugReport": "https://docs.google.com/forms/d/e/1FAIpQLSfCILvbJZOWAkCkrcMBFg99IMS9Nd7EFPU0ySg9FVgVgu52zQ/viewform",
        "opinionsAndRequests": "https://docs.google.com/forms/d/e/1FAIpQLSealByRyTsbUn23APVfK-uf0t2ziVJbtfci6HBiTwnXQHfSFA/viewform",
        "termsOfService": "https://firebasestorage.googleapis.com/v0/b/touch-42092.appspot.com/o/rules%2FTermsOfService.pdf?alt=media&token=c61575c9-66d2-4ba1-98a6-8d14adf6a07f",
        "privacyPolicy": "https://firebasestorage.googleapis.com/v0/b/touch-42092.appspot.com/o/rules%2FPrivacyPolicy.pdf?alt=media&token=a1405dd4-3d96-4a90-88ff-4acad9815eef",
        "safetyAndSecurityGuidelines": "https://firebasestorage.googleapis.com/v0/b/touch-42092.appspot.com/o/rules%2FSafetyAndSecurityGuidelines.pdf?alt=media&token=629ead64-9c71-41b3-bedd-41da2c0e20ed",
        "specialCommercialLaw": "https://firebasestorage.googleapis.com/v0/b/touch-42092.appspot.com/o/rules%2FSpecialCommercialLaw.pdf?alt=media&token=ec62ebac-bc27-456a-9319-09db8c9c9a1c"
    ]
    // 趣味カードカテゴリー
    let hobbyCardCategory = [
        "目的", "好きなもの", "趣味", "人間性・価値観",
        "ママ", "グルメ・お酒", "音楽", "スポーツ", "推し",
        "占い", "芸能人・テレビ", "ゲーム", "アート", "本・漫画",
        "ファッション", "旦那・彼氏", "職業", "なんでも"
    ]
    // 特定の情報を一時的に保管
    var specificUser: User?
    var specificRoom: Room?
    var specificInvitation: Invitation?
    var ownSpecificInvitation = [String:Any]()
    var globalInvitationList = [Invitation]()
    var globalInvitations = [Int:Invitation]()
    var globalFilterInvitations = [Int:Invitation]()
    var invitationSelectArea = "全て"
    var globalBoardList = [Board]()
    var boardSelectCategory = "全て"
    var globalHobbyCards = [HobbyCard]()
    var ownSpecificHobbyCard = [String:Any]()
    var selectedTagList = [String]()
    var tabBarVC: UITabBarController?
    
    // メッセージ一覧画面で一時的に使う
    var currentLatestRoomId: String?
    var unReadCountForCurrentLatestRoom: Int?
    var consectiveCountDictionary: [String: Int] = [:]
    
    // グローバルテーブル
    var messageListTableView = UITableView()
    var messageCollectionView: UICollectionView?
    var visitorTableView = UITableView()
    var invitationListTableView = UITableView()
    var boardTableView = UITableView()
    var goodTableView = UITableView()
    var pushNotificationSettingTableView = UITableView()
    var likeCardTableView = UITableView()
    var likeCardDetailTableView = UITableView()
    // グローバルコレクションビュー
    var recomMsgCollectionView = UICollectionView(
        frame: CGRect(x: 0, y: 0, width: 1000, height: 120),
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    // グローバルリスナー
    let db = Firestore.firestore()
    var userAdminCheckStatusListener: ListenerRegistration?
    var userDeactiveListener: ListenerRegistration?
    var userForceDeactiveListener: ListenerRegistration?
    var approachedListener: ListenerRegistration?
    var messageListListener: ListenerRegistration?
    var messageRoomListener: ListenerRegistration?
    var messageRoomTypingListener: ListenerRegistration?
    var boardListener: ListenerRegistration?
    var visitorListener: ListenerRegistration?
    var blockListener: ListenerRegistration?
    var violationListener: ListenerRegistration?
    var stopListener: ListenerRegistration?
    var hobbyCardListener: ListenerRegistration?
    // グローバルタイマー
    var timer: Timer?
    // グローバルカード情報
    var deckView = UIView()
    var contentView = UIView()
    var cardViews = [CardView]()
    var tutorialDeckView = UIView()
    var tutorialContentView = UIView()
    var tutorialCardViews = [CardView]()
    var cardSearchUserPage: Int = 1
    var cardPriorityUserPage: Int = 1
    var cardRecommendFilterFlg = false
    var cardViolationUser: User?
    var searchCardRecommendUsers = [User]()
    var searchCardUserEnd = false
    var pickupCardRecommendUsers = [User]()
    var pickupUserIndex: Int = 7
    var priorityCardRecommendUsers = [User]()
    var priorityCardUserEnd = false
    var cardApproachedUsers = [User]()
    var tutorialCardUsers = [User]()
    var likeCardUsers = [User]()
    var hobbyCategories = ["目的", "好きなもの", "趣味", "人間性・価値観", "職業", "食事", "音楽", "スポーツ"]
    // メッセージ関連
    var lastRoomDocument: QueryDocumentSnapshot?
    var messageInputView: MessageInputView?
    var talkView = UIStackView()
    var showTalkGuide: Bool = false
    var talkGuideCategory: String = ""
    var displayAutoMessage: Bool = false
    let defaultStickers = [
        UIImage(named: "default1"), UIImage(named: "default2"), UIImage(named: "default3"),
        UIImage(named: "default4"), UIImage(named: "default5"), UIImage(named: "default6"),
        UIImage(named: "default7"), UIImage(named: "default8"), UIImage(named: "default9"),
        UIImage(named: "default10")
    ] as! [UIImage]
    let defaultStickerIdentifier = [
        "default1", "default2", "default3", "default4", "default5",
        "default6", "default7", "default8", "default9", "default10"
    ]
    // 掲示板関連
    var boardList = [Board]()
    // 設定関連
    var iosNotificationIsPermitted = false
    var pushNotificationToggleSwitches: [UISwitch] = []
    // typesense設定情報
    let typesenseClient: Client = {
        let host = "o3zcb6j50fsxtyrnp.a1.typesense.net"
        let port = "443"
        let protocal = "https"
        let apiKey = "5nv0bn0iUk1TZVA9JEwOndsrBV3ym73C"
        
        let node = Node(host: host, port: port, nodeProtocol: protocal)
        let config = Configuration(nodes: [node], apiKey: apiKey)
        let client = Client(config: config)
        return client
    }()
}
