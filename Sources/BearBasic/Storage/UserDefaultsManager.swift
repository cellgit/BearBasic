//
//  File.swift
//  BearSdk
//
//  Created by liuhongli on 2024/12/4.
//

import Foundation

public struct UserDefaultsManager {
    
    // 存入数据: 数据需遵守Codable协议
    // 示例:
    // let model = UserModel(json) // UserModel需遵守Codable协议
    // UserDefaultsManager.save(model, forKey: UserDefaultsKey.user.key)
    public static func save<T: Codable>(_ data: T, forKey key: String) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encodedData, forKey: key)
        } catch {
            print("Save error: \(error)")
        }
    }
    
    // 获取数据
    // 示例:
    // let user: UserModel? = UserDefaultsManager.get(forKey: UserDefaultsKey.user.key)
    public static func get<T: Codable>(forKey key: String, ofType type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Get error: \(error)")
            return nil
        }
    }
    
    // 删除数据
    // 示例: UserDefaultsManager.delete(forKey: UserDefaultsKey.user.key)
    public static func delete(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // 增加的删除方法，带有成功和失败的回调是不必要的，因为UserDefaults的删除操作是即时的，
    // 并且如果键不存在，它也不会导致错误。因此，我们可以保持简单的删除方法。
    // 如果你需要根据删除的结果执行不同的逻辑，建议在调用删除方法后直接在代码中处理这些逻辑。
}
