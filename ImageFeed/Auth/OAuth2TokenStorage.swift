import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case tokenKey = "OAuth2TokenKey"
    }

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.tokenKey.rawValue)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.tokenKey.rawValue)
                if !isSuccess {
                    print("Ошибка: не удалось сохранить токен в Keychain")
                }
            } else {
                let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: Keys.tokenKey.rawValue)
                if !removeSuccessful {
                    print("Ошибка: не удалось удалить токен из Keychain")
                }
            }
        }
    }
}
