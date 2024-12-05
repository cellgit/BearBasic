//
//  File.swift
//  BearSdk
//
//  Created by liuhongli on 2024/12/4.
//

import Foundation

enum UserDefaultsKey {
    
    case token
    
    var key: String {
        switch self {
        case .token: return "bear_token"
        }
    }
    
}
