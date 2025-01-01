//
//  ErrorHandlerPlugin.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Moya
import Result
import SwiftUI

//只做统一的错误处理,如token失效等,外部的由外部调用的时候单独处理
class ErrorHandlerPlugin: PluginType {
    
    @AppStorage("isLogin") var isLoginStorage: Bool = false
    @AppStorage(BearUserDefaultsKey.appId.key) var appIdStorage: String = ""
    @AppStorage(BearUserDefaultsKey.token.key) var tokenStorage: String = ""
    
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
    
    
    /*
     // 定义业务码枚举
     export enum BusinessCode {
         UserNotFound = 1002, // 用户不存在
         InvalidCredentials = 1003, // 无效的凭证
         Unauthorized = 1004, // 未授权
         Forbidden = 1005, // 禁止访问
         ResourceNotFound = 1006, // 资源未找到
         ServerError = 1007, // 服务器错误
         ValidationFailed = 1008, // 验证失败

         FormatErrorNeedUUID = 1101, // idfa,idfv,uuid需要使用UUID格式

         MissingHeaderAppId = 4001, // Header未传入appId
         MissingHeaderUUID = 4002, // Header未传入uuid

         

         // 考试App_业务码为1开头，根据需要添加更多的业务码
         ExamIdNotFound = 11001, // 试卷id不存在
         ExamNotFound = 11002, // 试卷不存在
         MissingExamIdParam = 13001, // 请传入试卷id
         MissingResourceIdParam = 13002, // 请传入资源id

         PermissionDenied_NotSelfResource = 14001, // 用户权限不足，不是自己的资源
     }

     // 定义业务消息映射
     export const BusinessMessages: Record<BusinessCode, string> = {
         [BusinessCode.UserNotFound]: '用户不存在',
         [BusinessCode.InvalidCredentials]: '无效的凭证',
         [BusinessCode.Unauthorized]: '未授权',
         [BusinessCode.Forbidden]: '禁止访问',
         [BusinessCode.ResourceNotFound]: '资源未找到',
         [BusinessCode.ServerError]: '服务器错误',
         [BusinessCode.ValidationFailed]: '验证失败',
         [BusinessCode.ExamIdNotFound]: '试卷id不存在',
         [BusinessCode.ExamNotFound]: '试卷不存在',
         [BusinessCode.MissingExamIdParam]: '请传入参数examId',
         [BusinessCode.MissingResourceIdParam]: '请传入资源id',
         [BusinessCode.MissingHeaderAppId]: 'Header未传入appId',
         [BusinessCode.MissingHeaderUUID]: 'uuid',
         [BusinessCode.FormatErrorNeedUUID]: 'idfa,idfv,uuid需要使用uuid格式',

         [BusinessCode.PermissionDenied_NotSelfResource]: '用户权限不足，不是自己的资源',

     };
     */
    
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
        case 1002:
            // 用户不存在
            debugPrint("Error Code is 1002, 错误信息: \(message)")
            
            // 退出登录,用户偏好清除bearer token, isLogin变为false
            logout()
            
            break
        case 1003:
            // 无效的凭证
            debugPrint("Error Code is 1003, 错误信息: \(message)")
            break
        case 1004:
            // 未授权
            debugPrint("Error Code is 1004, 错误信息: \(message)")
            break
        case 1005:
            // 禁止访问
            debugPrint("Error Code is 1005, 错误信息: \(message)")
            break
        case 1006:
            // 资源未找到
            debugPrint("Error Code is 1006, 错误信息: \(message)")
            break
        case 1007:
            // 服务器错误
            debugPrint("Error Code is 1007, 错误信息: \(message)")
            break
        case 1008:
            // 验证失败
            debugPrint("Error Code is 1008, 错误信息: \(message)")
            break
        case 1101:
            // idfa,idfv,uuid需要使用UUID格式
            debugPrint("Error Code is 1101, 错误信息: \(message)")
            break
        case 4001:
            // Header未传入appId
            debugPrint("Error Code is 4001, 错误信息: \(message)")
            break
        case 4002:
            // Header未传入uuid
            debugPrint("Error Code is 4002, 错误信息: \(message)")
            break
        case 11001:
            // 试卷id不存在
            debugPrint("Error Code is 11001, 错误信息: \(message)")
            break
        case 11002:
            // 试卷不存在
            debugPrint("Error Code is 11002, 错误信息: \(message)")
            break
        case 13001:
            // 请传入试卷id
            debugPrint("Error Code is 13001, 错误信息: \(message)")
            break
        case 13002:
            // 请传入资源id
            debugPrint("Error Code is 13002, 错误信息: \(message)")
            break
        case 14001:
            // 用户权限不足，不是自己的资源
            debugPrint("Error Code is 14001, 错误信息: \(message)")
            break
        default:
            break
        }
    }
}

extension ErrorHandlerPlugin {
    // 退出登录
    func logout() {
        // 退出登录,用户偏好清除bearer token, isLogin变为false
        isLoginStorage = false
        tokenStorage = ""
        // 清除用户信息
        UserDefaultsManager.delete(forKey: "userInfo")
        
        UserDefaultsManager.delete(forKey: BearUserDefaultsKey.token.key)
    }
        
    
}
