//
//  LoggerPlugin.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya

private typealias PluginConfiguration = NetworkLoggerPlugin.Configuration
private typealias PluginOptions = PluginConfiguration.LogOptions
private typealias PluginFormatter = PluginConfiguration.Formatter


let LoggerPlugin: NetworkLoggerPlugin = {
    let options: NetworkLoggerPlugin.Configuration.LogOptions = [
        PluginOptions.requestBody,
        PluginOptions.successResponseBody,
        PluginOptions.errorResponseBody
    ]
    return NetworkLoggerPlugin.init(configuration: .init(formatter: PluginFormatter(entry: { identifier, message, type in
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let date = formatter.string(from: Date())
        guard let identifierType = IdentifierType(rawValue: identifier), identifierType != .response else {
            return ""
        }
        
        switch identifierType {
        case .responseBody:
            //todo 打印需要去掉转义
            return "网络请求日志: [\(date)] \(type)  \(identifierType.rawValue): \(message)"
        default:
            return "网络请求日志: [\(date)] \(type) \(identifierType.rawValue): \(message)"
        }
    }), output: { type, items in
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~网络日志开始~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        for item in items {
            if item.isEmpty == false {
                print(item, separator: ",", terminator: "\n")
            }
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~网络日志结束~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    }, logOptions: options))
}()
private enum IdentifierType: RawRepresentable {
    case request
    case requestBody
    case response
    case responseBody
    case error
    
    init?(rawValue: String) {
        switch rawValue {
        case "Request": self = .request
        case "Request Body": self = .requestBody
        case "Response": self = .response
        case "Response Body": self = .responseBody
        case "Error": self = .error
        default:return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .request:
            return "请求地址"
        case .requestBody:
            return "请求参数"
        case .response:
            return "请求结果"
        case .responseBody:
            return "返回结果"
        case .error:
            return "系统错误"
        }
    }
}

