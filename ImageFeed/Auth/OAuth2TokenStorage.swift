import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "AuthToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                if !isSuccess {
                    print("Ошибка: не удалось сохранить токен в Keychain")
                }
            } else {
                let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !removeSuccessful {
                    print("Ошибка: не удалось удалить токен из Keychain")
                }
            }
        }
    }
}

