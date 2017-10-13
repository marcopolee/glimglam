//
//  GitLabAPI.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 13/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

enum APIResult<T> {
    case Error(string: String)
    case Result(result: T)
}

class GitLabAPI {
    func postOAuthToken(clientId: String, clientSecret: String, code: String, grantType: String, redirectURI: String, completion: @escaping ((APIResult<GitLabAccessToken>) -> Void)) {
        var cmp = URLComponents(string: "https://gitlab.com/oauth/token")!
        cmp.queryItems = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": grantType,
            "redirect_uri": redirectURI
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = cmp.url else {
            completion(APIResult.Error(string: "Internal error"))
            return
        }
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: urlReq) { data, resp, err in
            if let error = err {
                completion(APIResult.Error(string: error.localizedDescription))
                return
            }
            guard let jsonData = data else {
                completion(APIResult.Error(string: "Empty response"))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard let result = try? decoder.decode(GitLabAccessToken.self, from: jsonData) else {
                completion(APIResult.Error(string: "Invalid response (decode error)"))
                return
            }
            completion(APIResult.Result(result: result))
        }
        task.resume()
    }
}
