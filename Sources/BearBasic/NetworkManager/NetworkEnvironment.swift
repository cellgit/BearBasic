//
//  File.swift
//  BearBasic
//
//  Created by liuhongli on 2024/12/10.
//

import Foundation

public class NetworkEnvironment {
    //在此处设置全局的环境值
    nonisolated(unsafe) public static let shared: NetworkEnvironment = {
        
        let shared = NetworkEnvironment.init(apiEnvironment: .production)
        
        return shared
    }()


    //api环境
    public enum ApiEnvironment: Int, CaseIterable {
        //测试
        case test
        //生产
        case production
        
        case local
        
        #if DEBUG
        public var name: String {
            switch self {
            case .test:
                return "测试环境"
            case .production:
                return "生产环境"
                
            case .local:
                return "本地环境"
                
            }
        }
        #endif
    }

    //api环境，对应测试，预生产和生产，release下为生产，release下不允许修改，debug下在doKit服务下可以修改
//    #if DEBUG
//    public var apiEnvironment: ApiEnvironment
//    #else
//    public let apiEnvironment: ApiEnvironment
//    #endif
    
    // API 环境，DEBUG 模式下允许修改，RELEASE 模式下为只读
    #if DEBUG
    public var apiEnvironment: ApiEnvironment
    #else
    public private(set) var apiEnvironment: ApiEnvironment
    #endif
    
//    https://api.test.beartranslate.com/api/v1

    
    public var apiDomain: String {
        switch self.apiEnvironment {
            //发布
        case .production:
            return "https://api.beartranslate.com"
            //测试
        case .test:
            return "https://api.test.beartranslate.com"
        case .local:
            
            return "http://192.168.0.101:3000"
//            return "http://127.0.0.1:3000"
        }
    }
    
    // API 版本，默认值为 "v1"
    public private(set) var apiVersion: String = "v1"
    
    // 初始化构造函数
    private init(apiEnvironment: ApiEnvironment) {
        self.apiEnvironment = apiEnvironment
    }
    
    // 设置 API 版本
    public func setApiVersion(_ version: String) {
        self.apiVersion = version
    }
}
