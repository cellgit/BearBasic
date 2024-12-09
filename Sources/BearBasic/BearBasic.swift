// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public class BearBasic {
    
    private init() { }
    
    @MainActor public static let shared = BearBasic.init()
    
    public func start(with appId: String) {
        /// 存储appId
        UserDefaultsManager.save(appId, forKey: UserDefaultsKey.appId.key)
        
        ///  生成uuid
        ///  获取idfv
        ///`获取idfa`
        /// 获取platform
        /// appVersion
        /// bundleId
        /// attStatus
        
        
        // 生成 UUID
        let uuid = UUID().uuidString
        UserDefaultsManager.save(uuid, forKey: UserDefaultsKey.uuid.key)
        

        
        

    }
    
    
//    public func setAppId(with appId: String) {
//        UserDefaultsManager.save(appId, forKey: UserDefaultsKey.appId.key)
//    }
    
    public func getAppId() -> String? {
        UserDefaultsManager.get(forKey: UserDefaultsKey.appId.key, ofType: String.self)
    }
    

    
}


extension BearBasic {
    
//    private func getIDFA(completion: @escaping (String) -> Void) {
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                if status == .authorized {
//                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
//                } else {
//                    completion("unavailable")
//                }
//            }
//        } else {
//            let idfa = ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : "unavailable"
//            completion(idfa)
//        }
//    }
//    
//    @available(iOS 14, *)
//    private func getATTStatusString(_ status: ATTrackingManager.AuthorizationStatus) -> String {
//        switch status {
//        case .notDetermined: return "notDetermined"
//        case .restricted: return "restricted"
//        case .denied: return "denied"
//        case .authorized: return "authorized"
//        @unknown default: return "unknown"
//        }
//    }
    
    private var isIOS: Bool {
#if os(iOS)
        return true
#else
        return false
#endif
    }
    
    
    @MainActor private func getIDFV() -> String {
        if isIOS {
            return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        } else {
            // 在 macOS 上使用自定义逻辑
            return ProcessInfo.processInfo.globallyUniqueString
        }
    }
    
}
