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



/// **API 通用响应数据结构**
public struct ApiResponse<T: Decodable>: Decodable {
    public let code: Int
    public let message: String
    public let data: T
    
    public init(code: Int, message: String, data: T) {
        self.code = code
        self.message = message
        self.data = data
    }
}

public struct ApiJsonResponse: Decodable {
    public let code: Int
    public let message: String
    public let data: [String: Any]?

    public init(code: Int, message: String, data: [String: Any]?) {
        self.code = code
        self.message = message
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(Int.self, forKey: .code)
        self.message = try container.decode(String.self, forKey: .message)

        // 处理 `data` 是 JSON 字典
        if let jsonData = try? container.decode([String: AnyDecodable].self, forKey: .data) {
            self.data = jsonData.mapValues { $0.value }
        } else {
            self.data = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case code, message, data
    }
}



//public struct ApiJsonResponse<T: Decodable>: Decodable {
//    public let code: Int
//    public let message: String
//    public let data: T?
//    
//    public init(code: Int, message: String, data: T?) {
//        self.code = code
//        self.message = message
//        self.data = data
//    }
//    
//    // 自定义 `Decodable` 解析逻辑，支持 JSON 字典
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.code = try container.decode(Int.self, forKey: .code)
//        self.message = try container.decode(String.self, forKey: .message)
//        
//        // **优先解析为 `T`**
//        if let decodedData = try? container.decode(T.self, forKey: .data) {
//            self.data = decodedData
//        } else if let jsonData = try? container.decode([String: AnyDecodable].self, forKey: .data) {
//            self.data = jsonData as? T
//        } else {
//            self.data = nil
//        }
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case code, message, data
//    }
//}

public struct AnyDecodable: Decodable {
    public let value: Any
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let intValue = try? container.decode(Int.self) {
                value = intValue
            } else if let doubleValue = try? container.decode(Double.self) {
                value = doubleValue
            } else if let stringValue = try? container.decode(String.self) {
                value = stringValue
            } else if let boolValue = try? container.decode(Bool.self) {
                value = boolValue
            } else if let arrayValue = try? container.decode([AnyDecodable].self) {
                value = arrayValue.map { $0.value }
            } else if let dictionaryValue = try? container.decode([String: AnyDecodable].self) {
                value = dictionaryValue.mapValues { $0.value }
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyDecodable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode AnyDecodable"))
        }
    }
}


/// **业务错误定义**
public enum BusinessError: Error {
    case business(code: Int, message: String?)
}

/// **内部错误定义**
public enum InsideError: Error {
    case formatterError
}

/// **发送错误信息到 `ErrorHandlerPlugin`**
func sendError(response: Response) {
    do {
        let json = try response.mapJSON() as? [String: Any]
        
        // 处理 HTTP 状态码错误
        if !(200...299).contains(response.statusCode) {
            let message = json?["status_msg"] as? String ?? "Unknown error"
            ErrorHandlerPlugin().dealError(code: response.statusCode, message: message)
            return
        }
        
        // 解析 `result` 部分，业务码不等于 0，仅记录错误，但不拦截请求
        if let result = json?["result"] as? [String: Any],
           let code = result["code"] as? Int, code != 0 {
            let message = result["message"] as? String ?? "Unknown error"
            ErrorHandlerPlugin().dealError(code: code, message: message)
        }
    } catch {
        ErrorHandlerPlugin().dealError(code: -2, message: "Failed to parse response JSON")
        return
    }
}

public extension AnyPublisher where Output == Response, Failure == MoyaError {
    func mapResult<T: Decodable>() -> AnyPublisher<ApiResponse<T>, MoyaError> {
        self.flatMap { response -> AnyPublisher<ApiResponse<T>, MoyaError> in
            do {
                // 解析 JSON
                guard let json = (try? response.mapJSON()) as? [String: Any] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                sendError(response: response)  // **确保 JSON 解析成功后再调用**
                
                // **1. 处理 HTTP 状态码错误**
                let statusCode = json["status_code"] as? Int ?? -1
                if !(200...299).contains(statusCode) {
                    let message = json["status_msg"] as? String ?? "Unknown error"
                    return Fail(error: MoyaError.underlying(BusinessError.business(code: statusCode, message: message), nil))
                        .eraseToAnyPublisher()
                }
                
                // **2. 获取 `result`**
                guard let resultData = json["result"] as? [String: Any] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                let businessCode = resultData["code"] as? Int ?? 0
                let businessMessage = resultData["message"] as? String ?? "Success"
                
                // **3. 业务逻辑错误，仍然返回 `.failure`**
                if businessCode != 0 {
                    return Fail(error: MoyaError.underlying(BusinessError.business(code: businessCode, message: businessMessage), nil))
                        .eraseToAnyPublisher()
                }
                
                // **4. 解析 `data`**
                guard let data = resultData["data"] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                // **5. 进行 JSON 解析**
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                // **6. 解析 `T`**
                guard let decodedData = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                // **7. 返回 `APIResponse<T>` 结构体**
                let apiResponse = ApiResponse(code: businessCode, message: businessMessage, data: decodedData)
                return Just(apiResponse)
                    .setFailureType(to: MoyaError.self)
                    .eraseToAnyPublisher()
                
            } catch {
                return Fail(error: MoyaError.underlying(error, nil))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
}

public extension AnyPublisher where Output == Response, Failure == MoyaError {
    
    /// **解析 API 响应为 JSON 字典**
    func mapJsonResult() -> AnyPublisher<ApiJsonResponse, MoyaError> {
        self.flatMap { response -> AnyPublisher<ApiJsonResponse, MoyaError> in
            do {
                // 解析 JSON
                guard let json = (try? response.mapJSON()) as? [String: Any] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                sendError(response: response)  // 记录错误日志
                
                // **1. 解析 `status_code`，处理 HTTP 级别错误**
                let statusCode = json["status_code"] as? Int ?? -1
                if !(200...299).contains(statusCode) {
                    let message = json["status_msg"] as? String ?? "Unknown error"
                    return Fail(error: MoyaError.underlying(BusinessError.business(code: statusCode, message: message), nil))
                        .eraseToAnyPublisher()
                }
                
                // **2. 解析 `result`**
                guard let resultData = json["result"] as? [String: Any] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                let businessCode = resultData["code"] as? Int ?? 0
                let businessMessage = resultData["message"] as? String ?? "Success"
                
                // **3. 业务逻辑错误，直接返回 `.failure`**
                if businessCode != 0 {
                    return Fail(error: MoyaError.underlying(BusinessError.business(code: businessCode, message: businessMessage), nil))
                        .eraseToAnyPublisher()
                }
                
                // **4. 解析 `data` 为 JSON 字典**
                guard let data = resultData["data"] as? [String: Any] else {
                    return Fail(error: MoyaError.underlying(InsideError.formatterError, nil))
                        .eraseToAnyPublisher()
                }
                
                // **5. 返回 `ApiResponse<[String: Any]>`**
                let apiResponse = ApiJsonResponse(code: businessCode, message: businessMessage, data: data)
                return Just(apiResponse)
                    .setFailureType(to: MoyaError.self)
                    .eraseToAnyPublisher()
                
            } catch {
                return Fail(error: MoyaError.underlying(error, nil))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}









///// 业务错误定义
//public enum BusinessError: Error {
//    case business(code: Int, message: String?)
//}
//
///// 内部错误定义
//public enum InsideError: Error {
//    /// 服务器返回的格式不对，解析不到 `result` 和 `status_code` 字段
//    case formatterError
//}
//
///// 发送错误信息到 `ErrorHandlerPlugin`
//func sendError(response: Response) {
//    do {
//        let json = try response.mapJSON() as? [String: Any]
//
//        // 处理 HTTP 状态码
//        if !(200...299).contains(response.statusCode) {
//            let message = json?["status_msg"] as? String ?? "Unknown error"
//            ErrorHandlerPlugin().dealError(code: response.statusCode, message: message)
//            return
//        }
//
//        // 解析 `result` 部分
//        if let result = json?["result"] as? [String: Any],
//           let code = result["code"] as? Int {
//            let message = result["message"] as? String ?? "Unknown error"
//            ErrorHandlerPlugin().dealError(code: code, message: message)
//        } else {
//            // `result` 字段解析失败
//            ErrorHandlerPlugin().dealError(code: -1, message: "Invalid response format")
//        }
//
//    } catch {
//        // JSON 解析失败
//        ErrorHandlerPlugin().dealError(code: -2, message: "Failed to parse response JSON")
//    }
//}
//
//public extension AnyPublisher where Output == Response, Failure == MoyaError {
//
//    /// **通用数据解析方法**
//    func mapResult<T: Decodable>() -> AnyPublisher<T, MoyaError> {
//        self.flatMap { response -> AnyPublisher<T, MoyaError> in
//            sendError(response: response)
//
//            do {
//                // 解析 JSON
//                guard let json = try response.mapJSON() as? [String: Any] else {
//                    throw InsideError.formatterError
//                }
//
//                // 获取状态码
//                guard let statusCode = json["status_code"] as? Int else {
//                    throw InsideError.formatterError
//                }
//
//                // 业务逻辑错误
//                guard (200...299).contains(statusCode), let resultData = json["result"] else {
//                    let message = json["status_msg"] as? String ?? "Unknown error"
//                    throw BusinessError.business(code: statusCode, message: message)
//                }
//
//                // 解析 `data` 部分
//                guard let result = resultData as? [String: Any],
//                      let data = result["data"] else {
//                    throw InsideError.formatterError
//                }
//
//                // 进行 JSON 解析
//                let jsonData = try JSONSerialization.data(withJSONObject: data)
//                let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
//                return Just(decodedData)
//                    .setFailureType(to: MoyaError.self)
//                    .eraseToAnyPublisher()
//                
//            } catch {
//                return Fail(error: MoyaError.underlying(error, nil)).eraseToAnyPublisher()
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//
//    /// **适用于 `SwiftData` 的数据映射方法**
//    func mapResultSwiftData() -> AnyPublisher<Any?, MoyaError> {
//        self.tryMap { (response: Response) -> Any? in
//            sendError(response: response)
//
//            // 解析 JSON
//            guard let json = try? response.mapJSON() as? [String: Any] else {
//                throw InsideError.formatterError
//            }
//
//            // 获取状态码
//            guard let statusCode = json["status_code"] as? Int else {
//                throw InsideError.formatterError
//            }
//
//            // 业务逻辑错误
//            guard (200...299).contains(statusCode) else {
//                let message = json["status_msg"] as? String ?? "Unknown error"
//                throw BusinessError.business(code: statusCode, message: message)
//            }
//
//            // 返回 `result` 作为 `Any?`
//            return json["result"]
//        }
//        .mapError { error -> MoyaError in
//            MoyaError.underlying(error, nil)
//        }
//        .eraseToAnyPublisher()
//    }
//}
