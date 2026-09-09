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

#if os(iOS)
        /// 设备类型在这里（主线程）种一次缓存。
        /// 请求拦截器跑在 Alamofire 的队列上，读它时绝不能再回主线程等——
        /// 那会和「在主线程上发起请求」成环，把 App 冻死。详见 `isPad`。
        seedDeviceIdiomCacheIfNeeded()
#endif
        
        
        
        
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
