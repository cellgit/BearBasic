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

// 延迟属性，保证在主线程访问
var isPad: Bool {
    DispatchQueue.main.sync {
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



