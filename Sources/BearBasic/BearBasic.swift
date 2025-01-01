// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public class BearBasic {
    
    private init() { }
    
    @MainActor public static let shared = BearBasic.init()
    
    @AppStorage(BearUserDefaultsKey.uuid.key) var uuidStorage: String = ""
    @AppStorage(BearUserDefaultsKey.appId.key) var appIdStorage: String = ""
    
    
    /// 启动sdk,需要提前设置的参数,可以在这里设置
    /// - Parameter appId: appId
    /// - Parameter env: 网络环境,默认production
    public func start(with appId: String, env: NetworkEnvironment.ApiEnvironment = .production, apiVersion: String = "v1") {
        
        /// 设置网络环境
#if DEBUG
        NetworkEnvironment.shared.apiEnvironment = env
#else
//        NetworkEnvironment.shared.apiEnvironment = env
#endif
        
        /// 设置api版本
        NetworkEnvironment.shared.setApiVersion(apiVersion)
        appIdStorage = appId
        uuidStorage = UUID().uuidString
        
        
        
        
        /// 存储appId
//        UserDefaultsManager.save(appId, forKey: UserDefaultsKey.appId.key)
        
        // 生成 UUID
//        let uuid = UUID().uuidString
//        UserDefaultsManager.save(uuid, forKey: UserDefaultsKey.uuid.key)
        

    }
    
//    public func getAppId() -> String? {
//        UserDefaultsManager.get(forKey: UserDefaultsKey.appId.key, ofType: String.self)
//    }

    
}


extension BearBasic {
    
    private var isIOS: Bool {
#if os(iOS)
        return true
#else
        return false
#endif
    }
    
}
