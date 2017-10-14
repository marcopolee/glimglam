//
//  GitLabAPI.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 13/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

public enum APIResult<T> {
    case Error(string: String)
    case Result(result: T)
}

public enum GitLab {
    public struct Project: Codable {
        public let id: UInt64
        public let description: String?
        public let name: String
        public let path: String
        public let pathWithNamespace: String
        public let lastActivityAt: Date
        
        public enum CodingKeys: String, CodingKey {
            case id
            case description
            case name
            case path
            case pathWithNamespace = "path_with_namespace"
            case lastActivityAt = "last_activity_at"
        }
    }
    
    public struct Pipeline: Codable {
        public enum Status: String, Codable {
            case Running = "running"
            case Pending = "pending"
            case Success = "success"
            case Failed = "failed"
            case Canceled = "canceled"
            case Skipped = "skipped"
        }
        public let id: UInt64
        public let status: Status?
        public let ref: String?
        public let sha: String?
    }
    
    public struct AccessToken: Codable {
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
    
    public class API {
        private func loggedInRequest(accessToken: AccessToken, path: String, queryParams: [String: String] = [:]) -> URLRequest {
            var cmp = URLComponents(string: "https://gitlab.com\(path)")!
            cmp.queryItems = queryParams.map{ URLQueryItem(name: $0.key, value: $0.value) }
            var urlReq = URLRequest(url: cmp.url!)
            urlReq.httpMethod = "GET"
            return urlReq
        }
        
        private func executeAPI<RetType: Codable>(urlRequest: URLRequest, completion: @escaping ((APIResult<RetType>) -> Void)) {
            let task = URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
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
                guard let result = try? decoder.decode(RetType.self, from: jsonData) else {
                    completion(APIResult.Error(string: "Invalid response (decode error)"))
                    return
                }
                completion(APIResult.Result(result: result))
            }
            task.resume()
        }
        
        public func postOAuthToken(clientId: String, clientSecret: String, code: String, grantType: String, redirectURI: String, completion: @escaping ((APIResult<AccessToken>) -> Void)) {
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
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getProjects(accessToken: AccessToken, completion: @escaping ((APIResult<Project>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/projects")
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getProjectPipelines(accessToken: AccessToken, project: Project, status: Pipeline.Status, completion: @escaping ((APIResult<Pipeline>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/projects/\(project.id)/pipelines", queryParams: ["status": status.rawValue])
            executeAPI(urlRequest: urlReq, completion: completion)
        }
    }
}
