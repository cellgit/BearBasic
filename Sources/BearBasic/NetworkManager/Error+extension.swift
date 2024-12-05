//
//  Error+extension.swift
//  Tenant
//
//  Created by liuhongli on 2024/4/4.
//

import Foundation
import Combine
import Moya

enum AppError: Error {
    case networkError(String)
    case decodingError
    case unknown
    
    // 添加更多错误类型根据你的需要
}


extension Publisher where Output == ProgressResponse, Failure == MoyaError {
    func mapToAppError() -> AnyPublisher<ProgressResponse, AppError> {
        self.mapError { moyaError -> AppError in
            // 这里转换 MoyaError 到 AppError
            switch moyaError {
            case .statusCode(let response):
                return .networkError("Network error with status code: \(response.statusCode)")
            case .imageMapping, .jsonMapping, .stringMapping, .objectMapping(_, _):
                return .decodingError
            default:
                return .unknown
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == ProgressResponse, Failure == MoyaError {
    // 处理进度和响应
    func mapProgressResponse() -> AnyPublisher<ProgressResponse, Failure> {
        self.flatMap { progressResponse -> AnyPublisher<ProgressResponse, Failure> in
            // 直接通过Just返回ProgressResponse，这里假设progressResponse已经是期望的类型
            Just(progressResponse)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
