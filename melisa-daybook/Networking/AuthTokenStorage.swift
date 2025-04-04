//
//  AuthTokenStorage.swift
//  PackItApp
//
//  Created by Kirill Ushkov on 27.12.2024.
//
import Foundation

public struct AuthTokenStorage: Sendable {
    public let accessToken: @Sendable () -> String?
    public let setAccessToken: @Sendable (String) -> Void
    public let clear: @Sendable () -> Void
    public let isLoggedIn: @Sendable () -> Bool
    
    public init(accessToken: @escaping @Sendable () -> String?, setAccessToken: @escaping @Sendable (String) -> Void, clear: @escaping @Sendable () -> Void, isLoggedIn: @escaping @Sendable () -> Bool) {
        self.accessToken = accessToken
        self.setAccessToken = setAccessToken
        self.clear = clear
        self.isLoggedIn = isLoggedIn
    }
}

extension AuthTokenStorage {
    public static var live: Self {
        let key = "accessToken"
        return .init(
            accessToken: {
                UserDefaults.standard.string(forKey: key)
            },
            setAccessToken: { value in
                UserDefaults.standard.set(value, forKey: key)
            },
            clear: {
                UserDefaults.standard.removeObject(forKey: key)
            },
            isLoggedIn: {
                UserDefaults.standard.string(forKey: key) != nil
            }
        )
    }
}
