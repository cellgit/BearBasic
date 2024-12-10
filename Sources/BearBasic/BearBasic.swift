// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public class BearBasic {
    
    private init() { }
    
    @MainActor public static let shared = BearBasic.init()
    
    
    /// 启动sdk,需要提前设置的参数,可以在这里设置
    /// - Parameter appId: appId
    public func start(with appId: String) {
        /// 存储appId
        UserDefaultsManager.save(appId, forKey: UserDefaultsKey.appId.key)
        
        // 生成 UUID
        let uuid = UUID().uuidString
        UserDefaultsManager.save(uuid, forKey: UserDefaultsKey.uuid.key)

    }
    
    public func getAppId() -> String? {
        UserDefaultsManager.get(forKey: UserDefaultsKey.appId.key, ofType: String.self)
    }

    
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
