//
//  FilterPlugin.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya

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
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        var newRequest = request
        newRequest.setValue("Content-Type", forHTTPHeaderField: "application/json".urlEncoded)
        if let token = UserDefaultsManager.get(forKey: UserDefaultsKey.token.key, ofType: String.self) {
            newRequest.setValue(token, forHTTPHeaderField: token)
        }
        newRequest.timeoutInterval = 300
        return newRequest
    }
    
}
