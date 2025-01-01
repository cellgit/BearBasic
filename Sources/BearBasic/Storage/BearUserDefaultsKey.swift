//
//  File.swift
//  BearSdk
//
//  Created by liuhongli on 2024/12/4.
//

import Foundation

/// BearUserDefaultsKey,外部获取和存取`appId`, `token`, `isLogin`这些值必须使用这些key
public enum BearUserDefaultsKey: String {
    
    case appId
    case token
    case isLogin
    case uuid
    
    public var key: String {
        self.rawValue
    }
    
}
