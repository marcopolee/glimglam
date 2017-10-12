//
//  GitLabAccessToken.swift
//  GlimglamCore
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

public struct GitLabAccessToken: Codable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: TimeInterval
    public let refreshToken: String
    
    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}
