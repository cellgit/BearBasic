//
//  BaseTargetType.swift
//  Tenant
//
//  Created by liuhongli on 2024/3/26.
//

import Foundation
import Moya

public protocol BaseTargetType: TargetType {
    var base: String { get }
    var commonHeaders: [String: String] { get }
    var commonHeadersWithoutToken: [String: String] { get }
    var formDataHeaders: [String: String] { get }
}

public extension BaseTargetType {
    var baseURL: URL {
        return URL(string: base)!
    }
    
    var headers: [String: String]? {
        return commonHeaders
    }
}

// 定义共用的属性
public extension BaseTargetType {
    var base: String {
        return "http://47.116.24.54:3001/api/v1"
    }
    
    var commonHeaders: [String: String] {
        if let token = UserDefaultsManager.get(forKey: UserDefaultsKey.token.key, ofType: String.self) {
            return [
                "Content-Type": "application/json",
                "Authorization": token
            ]
        }
        else {
            return [
                "Content-Type": "application/json"
            ]
        }
    }
    
    var commonHeadersWithoutToken: [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    var formDataHeaders: [String: String] {
        if let token = UserDefaultsManager.get(forKey: UserDefaultsKey.token.key, ofType: String.self) {
            return [
                "Content-Type": "multipart/form-data",
                "Authorization": token
            ]
        }
        else {
            return [
                "Content-Type": "multipart/form-data"
            ]
        }
    }
    
}

public extension BaseTargetType {
    // 提供一个处理 JSON Body 数据的默认实现
    func jsonTask(parameters: [String: Any]) -> Task {
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
}

// 默认情况下，所有的请求都假定使用这种方式传递参数
public extension BaseTargetType {
    var task: Task {
        return .requestPlain // 仅作为占位符，具体实现应该根据实际情况替换
    }
}

