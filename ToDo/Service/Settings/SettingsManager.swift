import Foundation

@MainActor
class SettingsManager {
    
    enum Keys {
        static let storage = "storage"
        static let token = "token"
    }
    
    static var shared = SettingsManager()
    
    var storage: StorageType {
        get {
            guard
                let string = UserDefaults.standard.string(forKey: Keys.storage),
                let storage = StorageType(rawValue: string)
            else { return .swiftData }
            
            return storage
        } set {
            guard newValue != storage else { return }
            
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Keys.storage)
        }
    }
    
    var token: String {
        get {
            if let data = KeychainService.load(key: Keys.token),
               let token = String(data: data, encoding: .unicode) {
                return token
            }
            
            return ""
        }
        set {
            let data = newValue.data(using: .unicode)!
            KeychainService.save(key: Keys.token, data: data)
        }
    }
    
    private init() { 
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFromSettingsBundle),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func updateFromSettingsBundle() {
        guard
            let string = UserDefaults.standard.string(forKey: Keys.storage),
            let storage = StorageType(rawValue: string)
        else { return }
        
        self.storage = storage
    }
}
