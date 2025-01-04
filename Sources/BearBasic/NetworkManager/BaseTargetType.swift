//
//  BaseTargetType.swift
//  Tenant
//
//  Created by liuhongli on 2024/3/26.
//

import Foundation
import Moya
import UniformTypeIdentifiers
import SwiftUI

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
        return NetworkEnvironment.shared.apiDomain + "/api/" + NetworkEnvironment.shared.apiVersion
    }
    
    var commonHeaders: [String: String] {
        if let token = UserDefaultsManager.get(forKey: BearUserDefaultsKey.token.key, ofType: String.self) {
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
        if let token = UserDefaultsManager.get(forKey: BearUserDefaultsKey.token.key, ofType: String.self) {
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
    
    func urlTask(parameters: [String: Any]) -> Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    func task(parameters: [String: Any], isBody: Bool = true) -> Task {
        if isBody == false {
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
        else {
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
}


public extension BaseTargetType {
    // 通用文件上传任务
    func uploadTask(fileURL: URL, fileName: String, mimeType: String) -> Task {
        let fileData: Data
        do {
            fileData = try Data(contentsOf: fileURL)
        } catch {
            fatalError("无法读取文件: \(error.localizedDescription)")
        }
        
        let multipartFormData = MultipartFormData(provider: .data(fileData),
                                                  name: "file",
                                                  fileName: fileName,
                                                  mimeType: mimeType)
        
        return .uploadMultipart([multipartFormData])
    }
    
    // 通用文件上传任务，支持附加文本参数, 实现灵活,可自由传递 `mimeType`
    
    func uploadTask(fileURL: URL, fileName: String, mimeType: String? = nil, additionalParameters: [String: Any]? = nil) -> Task {
        let fileData: Data
        do {
            fileData = try Data(contentsOf: fileURL)
        } catch {
            fatalError("无法读取文件: \(error.localizedDescription)")
        }
        
        var multipartData: [MultipartFormData] = []
        
        var mimeType = mimeType
        
        if mimeType == nil {
            mimeType = determineMimeType(for: fileURL)
        }
        
        // 添加文件数据
        let fileFormData = MultipartFormData(provider: .data(fileData),
                                             name: "file",
                                             fileName: fileName,
                                             mimeType: mimeType)
        multipartData.append(fileFormData)
        
        if let parameters = additionalParameters {
            for (key, value) in parameters {
                // 转换不同类型的 value 为 Data
                let valueString: String
                if let stringValue = value as? String {
                    valueString = stringValue
                } else if let intValue = value as? Int {
                    valueString = "\(intValue)" // 将 Int 转为 String
                } else if let boolValue = value as? Bool {
                    valueString = boolValue ? "true" : "false" // 将 Bool 转为 String
                } else {
                    print("Unsupported value type for key \(key): \(type(of: value))")
                    continue
                }
                
                // 将 String 转为 Data，并创建 MultipartFormData
                if let data = valueString.data(using: .utf8) {
                    let textFormData = MultipartFormData(
                        provider: .data(data),
                        name: key
                    )
                    multipartData.append(textFormData)
                } else {
                    print("Failed to encode value for key \(key) to Data.")
                }
            }
        }
        return .uploadMultipart(multipartData)
    }
    
    
    /// 常见 `mimeType` 类型
    /// - Parameter fileURL: 文件路径
    /// - Returns: mimeType
    private func determineMimeType(for fileURL: URL) -> String {
        switch fileURL.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt": return "application/vnd.ms-powerpoint"
        case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt": return "text/plain"
        case "json": return "application/json"
        case "xml": return "application/xml"
        case "csv": return "text/csv"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "bmp": return "image/bmp"
        case "svg": return "image/svg+xml"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "ogg": return "audio/ogg"
        case "mp4": return "video/mp4"
        case "zip": return "application/zip"
        case "rar": return "application/x-rar-compressed"
        case "7z": return "application/x-7z-compressed"
        case "gz": return "application/gzip"
        default: return "application/octet-stream" // 默认二进制类型
        }
    }
    
    
}

// 默认情况下，所有的请求都假定使用这种方式传递参数
public extension BaseTargetType {
    var task: Task {
        return .requestPlain // 仅作为占位符，具体实现应该根据实际情况替换
    }
}



//        // 添加文本参数
//        if let parameters = additionalParameters {
//            for (key, value) in parameters {
//                let textFormData = MultipartFormData(provider: .data(value.data(using: .utf8) ?? Data()),
//                                                    name: key)
//                multipartData.append(textFormData)
//            }
//        }
