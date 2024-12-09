//
//  File.swift
//  BearSdk
//
//  Created by liuhongli on 2024/12/4.
//

import Foundation

enum UserDefaultsKey {
    
    case token
    case appId
    
    case uuid
    
    var key: String {
        switch self {
        case .token: return "bear_token"
        case .appId: return "bear_app_id"
        case .uuid: return "bear_uuid"
            
            
        }
    }
    
}
