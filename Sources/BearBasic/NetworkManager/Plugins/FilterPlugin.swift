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

/// 缓存下来的设备类型。启动时在主线程种一次，之后任何线程直接读。
///
/// 只在主线程写、其余线程只读一个 `Bool`，所以 `nonisolated(unsafe)` 是成立的。
nonisolated(unsafe) private var cachedIsPad: Bool?

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
/// 2026-09-09 在 gkzt 上实锤过：连着打几个点（进详情页再切 Tab）就必现。
///
/// `UIDevice` 是 `@MainActor` 隔离的，没法在全局 `let` 里直接算；
/// 而 `userInterfaceIdiom` 进程起来之后就不再变。所以启动时（`BearBasic.start`）
/// 在主线程种一次缓存，这里只做一次无锁读。
var isPad: Bool {
    if let cachedIsPad { return cachedIsPad }

    // 还没种过。在主线程就地补种；不在主线程就异步补种，
    // 这一次先按 iPhone 报——它只影响一个上报用的 header，
    // 不值得为它冒死锁的风险。
    seedDeviceIdiomCacheIfNeeded()
    return cachedIsPad ?? false
}

/// 种一次设备类型缓存。主线程上调用才会立即生效，其余线程转异步。
/// `BearBasic.start` 会在启动时调它，保证第一个网络请求就已经拿到正确的值。
func seedDeviceIdiomCacheIfNeeded() {
    guard cachedIsPad == nil else { return }

    guard Thread.isMainThread else {
        DispatchQueue.main.async { seedDeviceIdiomCacheIfNeeded() }
        return
    }

    cachedIsPad = MainActor.assumeIsolated {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
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



