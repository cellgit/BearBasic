//
//  ErrorHandlerPlugin.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya
import Result

//只做统一的错误处理,如token失效等,外部的由外部调用的时候单独处理
class ErrorHandlerPlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard let response = result.value else {
            return
        }
        //返回的数据必须能转json,且code必须为0,否则返回空(或者可以抛出一个错误)
        guard let json = (try? response.mapJSON()) as? [String: Any],
              let code = json["code"] as? Int
        else {
            return
        }
        dealError(code: code, message: json["message"])
    }
    
    func dealError(code: Int, message: Any?) {
        let message = message as? String ?? ""
        switch code {
        case 200...299:
            debugPrint("Error Code is \(code), 错误信息: \(message)")
            break
        case 300:
            debugPrint("Error Code is 300, 错误信息: \(message)")
        case 404:
            debugPrint("Error Code is 404, 错误信息: \(message)")
        case 500:
            //系统错误
            debugPrint("Error Code is 500, 错误信息: \(message)")
            break
        default:
            break
        }
    }
}

