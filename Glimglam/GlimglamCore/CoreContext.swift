//
//  CoreContext.swift
//  GlimglamCore
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

let gitLabAccessTokenService = "com.marcopolee.Glimglam.GitLabAccessToken"

public extension Notification.Name {
    public static let coreContextUpdate = Notification.Name("CoreContextUpdate")
}

private let notificationQueue = NotificationQueue(notificationCenter: NotificationCenter.default)

public class CoreContext: Codable {
    
    public var gitLabLogin: GitLab.AccessToken? {
        didSet {
            notificationQueue.enqueue(Notification(name: .coreContextUpdate), postingStyle: .whenIdle, coalesceMask: .onName, forModes: nil)
        }
    }
    public var user: GitLab.User? {
        didSet {
            notificationQueue.enqueue(Notification(name: .coreContextUpdate), postingStyle: .whenIdle, coalesceMask: .onName, forModes: nil)
        }
    }
    
    public func readFromKeychain() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: gitLabAccessTokenService as CFString,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue
        ]
        var maybeResult: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &maybeResult)
        guard let result = maybeResult,
            let data = result as? Data else {
                return
        }
        guard let newContext = try? JSONDecoder().decode(CoreContext.self, from: data) else {
            deletThis()
            return
        }
        gitLabLogin = newContext.gitLabLogin
        user = newContext.user
    }
    
    public func storeInKeychain() {
        guard let json = try? JSONEncoder().encode(self) else {
            return
        }
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: gitLabAccessTokenService as CFString,
            kSecValueData: json as CFData
        ]
        #if !TARGET_SIMULATOR
            query[kSecAttrAccessGroup] = kSecAttrAccessibleWhenUnlocked
        #endif
        
        switch SecItemCopyMatching(query as CFDictionary, nil) {
        case errSecSuccess:
            // Existing data in keychain, update it
            SecItemUpdate(query as CFDictionary, [kSecValueData: json as CFData] as CFDictionary)
        case errSecItemNotFound:
            // Add it
            SecItemAdd(query as CFDictionary, nil)
        default:
            return
        }
    }
    
    public func deletThis() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: gitLabAccessTokenService as CFString
        ]
        SecItemDelete(query as CFDictionary)
    }
}
