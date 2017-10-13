//
//  CoreContext.swift
//  GlimglamCore
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

let gitLabAccessTokenService = "com.marcopolee.Glimglam.GitLabAccessToken"

public struct CoreContext: Codable {
    public var gitLabLogin: GitLabAccessToken?
    
    public mutating func readFromKeychain() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: gitLabAccessTokenService as CFString,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue
        ]
        var maybeResult: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &maybeResult)
        guard let result = maybeResult,
            let data = result as? Data,
            let token = try? JSONDecoder().decode(GitLabAccessToken.self, from: data) else {
            return
        }
        gitLabLogin = token
    }
    
    public func storeInKeychain() {
        guard let gitLabLogin = gitLabLogin else {
            return
        }
        guard let json = try? JSONEncoder().encode(gitLabLogin) else {
            return
        }
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: gitLabAccessTokenService as CFString,
            kSecValueData: json as CFData
        ]
        #if !TARGET_IPHONE_SIMULATOR
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
}
