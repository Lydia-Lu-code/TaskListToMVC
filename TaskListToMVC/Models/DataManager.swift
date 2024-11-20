// (資料持久化)


import Foundation

enum DataManagerError: Error {
    case saveError(Error)
    case loadError(Error)
    case dataNotFound
}

protocol DataManagerProtocol {
    func save<T: Encodable>(_ data: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T
}

class DataManager: DataManagerProtocol {
    static let shared = DataManager()
    private init() {} // 私有化初始化方法以確保單例模式
    
    func save<T: Encodable>(_ data: T, forKey key: String) throws {
        print("DataManager - 開始保存資料")
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            UserDefaults.standard.set(encodedData, forKey: key)
            UserDefaults.standard.synchronize()
            print("資料已保存到 UserDefaults")
        } catch {
            print("保存失敗: \(error)")
            throw DataManagerError.saveError(error)
        }
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            throw DataManagerError.dataNotFound
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw DataManagerError.loadError(error)
        }
    }
}


