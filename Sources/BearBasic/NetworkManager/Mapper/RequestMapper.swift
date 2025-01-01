//
//  RequestMapper.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Combine
import Moya
import SwiftData
import CombineMoya


public enum BusinessError: Error {
    case business(code: Int, message: String?)
}



//@MainActor let errorPlugin = ErrorHandlerPlugin()

//内部错误
public enum InsideError: Error {
    //服务器返回的格式不对,解析不到result和code字段
    case formatterError
}


func sendError(response: Response) {
    // 错误处理
    if let json = try? response.mapJSON() as? [String: Any] {
        let resultData = json["result"]
        if let result = resultData as? [String: Any],
           let code = result["code"] as? Int {
            
            let message = result["message"] as? String ?? "Unknown error"
            // 发送到插件
            ErrorHandlerPlugin().dealError(code: code, message: message)
        }
    }
    
}

public extension AnyPublisher where Output == Response, Failure == MoyaError {
    
    func mapResult<T: Decodable>() -> AnyPublisher<T, MoyaError> {
        self.flatMap { response -> AnyPublisher<T, MoyaError> in
            
            sendError(response: response)
            
            // 尝试解析JSON数据
            guard let json = try? response.mapJSON() as? [String: Any],
                  let statusCode = json["status_code"] as? Int else {
                // 数据格式不正确，抛出内部错误
                let formatterError = MoyaError.underlying(InsideError.formatterError, nil)
                return Fail(error: formatterError).eraseToAnyPublisher()
            }
            // 检查业务逻辑错误
            guard (200...299).contains(statusCode), let resultData = json["result"] else {
                let message = json["status_msg"] as? String ?? "Unknown error"
                let businessError = MoyaError.underlying(BusinessError.business(code: statusCode, message: message), nil)
                return Fail(error: businessError).eraseToAnyPublisher()
            }
            
            // 尝试将结果转换为目标类型
            do {
                if let result = resultData as? [String: Any],
                   let data = result["data"] {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
                    return Just(decodedData)
                        .setFailureType(to: MoyaError.self)
                        .eraseToAnyPublisher()
                } else {
                    throw InsideError.formatterError
                }
            } catch {
                let decodeError = MoyaError.underlying(error, nil)
                return Fail(error: decodeError).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 针对 `SwiftData` 的数据映射方法
    func mapResultSwiftData() -> AnyPublisher<Any?, MoyaError> {
        self.tryMap { (response: Response) -> Any? in
            // 尝试解析 JSON 数据
            guard let json = try? response.mapJSON() as? [String: Any],
                  let code = json["status_code"] as? Int else {
                // 如果数据格式不正确，抛出内部错误
                throw InsideError.formatterError
            }
            
            // 检查业务逻辑错误（状态码范围 200 到 299 为成功）
            guard (200...299).contains(code) else {
                let message = json["status_msg"] as? String ?? "Unknown error"
                throw BusinessError.business(code: code, message: message)
            }
            
            // 如果成功，返回结果
            return json["result"]
        }
        // 处理转换过程中的错误，将它们转换为 `MoyaError`
        .mapError { error -> MoyaError in
            // 将所有错误包装为 `MoyaError.underlying`
            return MoyaError.underlying(error, nil)
        }
        .eraseToAnyPublisher()
    }
    
}
