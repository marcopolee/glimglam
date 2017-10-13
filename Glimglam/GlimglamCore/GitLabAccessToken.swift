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
    public let refreshToken: String
    public let createdAt: Date
    public let scope: String
    
    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
        case scope
    }
}
