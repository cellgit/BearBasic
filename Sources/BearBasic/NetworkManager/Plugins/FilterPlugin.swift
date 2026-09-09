//
//  FilterPlugin.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya
import SwiftUI

#if os(iOS)
import UIKit

/// 设备是不是 iPad。
///
/// **绝不能在这里 `DispatchQueue.main.sync`。**
///
/// 这个值会被下面的 `FilterPlugin.prepare` 读到，而 `prepare` 是 Moya 的请求
/// 拦截器，跑在 Alamofire 的 request queue 上；同时 Moya 的 `sendRequest`
/// 会从调用方线程 `sync` 到那条 request queue 上去建请求。于是只要有任何一个
/// 请求是在主线程上发起的，两条路就成环：
///
///     主线程 ──等──▶ request queue ──等(main.sync)──▶ 主线程
///
/// 两边都不放手，整个 App 冻死，最后被 watchdog 杀掉——在用户那儿表现为崩溃。
/// 2026-09-09 在 gkzt 上实锤过：连着打几个点就必现。
///
/// `userInterfaceIdiom` 是进程起来之后就不再变的常量，用全局 `let` 缓存一次，
/// 任何线程直接读，永不阻塞。
let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
#else
#endif

extension String {
#if canImport(Foundation)
/// SwifterSwift: URL escaped string.
///
///        "it's easy to encode strings".urlEncoded -> "it's%20easy%20to%20encode%20strings"
///
var urlEncoded: String {
    return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
}
#endif
}

class FilterPlugin: PluginType {
    
    @AppStorage(BearUserDefaultsKey.appId.key) var appIdStorage: String = ""
    @AppStorage(BearUserDefaultsKey.token.key) var tokenStorage: String = ""
    @AppStorage(BearUserDefaultsKey.uuid.key) var uuidStorage: String = ""
    
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        var newRequest = request
        newRequest.setValue(tokenStorage, forHTTPHeaderField: "Authorization")
        newRequest.setValue(appIdStorage, forHTTPHeaderField: "appId")
        newRequest.setValue(uuidStorage, forHTTPHeaderField: "uuid")
        // 获取平台信息
        let platform = getPlatform()
        // 获取 appVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        // 获取 bundleId
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        
        newRequest.setValue(platform, forHTTPHeaderField: "platform")
        newRequest.setValue(appVersion, forHTTPHeaderField: "appVersion")
        newRequest.setValue(bundleId, forHTTPHeaderField: "bundleId")
        let systemVersion = getSystemVersion()
        newRequest.setValue(systemVersion, forHTTPHeaderField: "systemVersion")
        
        newRequest.timeoutInterval = 300
        return newRequest
    }
    
}


extension FilterPlugin {
    
    func getSystemVersion() -> String {
#if os(iOS)
        return "\(getPlatform()) \(ProcessInfo.processInfo.operatingSystemVersionString)"
#elseif os(macOS)
        
        let system_version = "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
        debugPrint("system_version ========= \(system_version)")
        return system_version
#else
        return "unknown"
#endif
    }
    
    func getPlatform() -> String {
#if os(iOS)
        if isPad {
            return "iPadOS"
        }
        else {
            return "iOS"
        }
#else
        return "macOS"
#endif
    }
}



