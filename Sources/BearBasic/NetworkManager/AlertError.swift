//
//  AlertError.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/3.
//

import Foundation
import Moya

struct AlertError: Identifiable {
    let id = UUID() // 提供唯一标识符
    let message: String
}



protocol UserFriendlyError: Error {
    var friendlyMessage: String { get }
}

extension MoyaError: UserFriendlyError {
    var friendlyMessage: String {
        switch self {
        case .imageMapping, .jsonMapping, .stringMapping, .objectMapping(_, _), .encodableMapping(_), .requestMapping:
            return "数据解析错误，请稍后再试。"
        case .statusCode(let response):
            if response.statusCode == 404 {
                return "未找到信息，请稍后再试。"
            } else {
                return "服务器错误（\(response.statusCode)），请稍后再试。"
            }
        case .underlying(let nsError as NSError, _):
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    return "网络连接不可用，请检查你的网络设置。"
                case NSURLErrorTimedOut:
                    return "请求超时，请稍后重试。"
                default:
                    return "网络错误，请稍后再试。"
                }
            } else {
                return "未知错误，请联系支持。"
            }
        default:
            return self.localizedDescription //"未知错误，请稍后再试。"
        }
    }
}



/*
 
 假设`error`是某个Error实例
 let message = error.friendlyMessage
 显示message给用户
 
 */
//protocol UserFriendlyError: Error {
//    var friendlyMessage: String { get }
//}
//
//extension URLError: UserFriendlyError {
//    var friendlyMessage: String {
//        switch self.code {
//        case .notConnectedToInternet:
//            return "网络连接不可用，请检查你的网络设置。"
//        case .timedOut:
//            return "请求超时，请稍后重试。"
//        default:
//            return "网络出现问题，请稍后再试。"
//        }
//    }
//}

