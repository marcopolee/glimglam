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

private func dateDecodingStrategy(decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let dateStr = try container.decode(String.self)
    
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    if let date = formatter.date(from: dateStr) {
        return date
    }
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
    if let date = formatter.date(from: dateStr) {
        return date
    }
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    if let date = formatter.date(from: dateStr) {
        return date
    }
    throw GitLab.API.DateError.invalidDate
}

public enum GitLab {
    public struct Namespace: Codable {
        public enum Kind: String, Codable {
            case Group = "group"
            case User = "user"
        }
        public let id: UInt64
        public let name: String
        public let kind: Kind
    }
    
    public struct User: Codable {
        public let id: UInt64
        public let username: String
        public let name: String
    }
    
    public struct Project: Codable {
        public let id: UInt64
        public let name: String
        public let nameWithNamespace: String
        public let lastActivityAt: Date
        
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case nameWithNamespace = "name_with_namespace"
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
    
    public struct Job: Codable {
        public enum Status: String, Codable {
            case Created = "created"
            case Pending = "pending"
            case Running = "running"
            case Failed = "failed"
            case Success = "success"
            case Canceled = "canceled"
            case Skipped = "skipped"
            case Manual = "manual"
        }
        public let id: UInt64
        public let status: Status
        public let name: String
        public let stage: String
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
        enum DateError: String, Error {
            case invalidDate
        }
        
        private func loggedInRequest(accessToken: AccessToken, path: String, queryParams: [String: String] = [:]) -> URLRequest {
            var cmp = URLComponents(string: "https://gitlab.com/api/v4\(path)")!
            if queryParams.count > 0 {
                cmp.queryItems = queryParams.map{ URLQueryItem(name: $0.key, value: $0.value) }
            }
            var urlReq = URLRequest(url: cmp.url!)
            urlReq.httpMethod = "GET"
            urlReq.addValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
            return urlReq
        }
        
        private func executeAPI<RetType: Codable>(urlRequest: URLRequest, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom(dateDecodingStrategy), completion: @escaping ((APIResult<RetType>) -> Void)) {
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
                decoder.dateDecodingStrategy = dateDecodingStrategy
                do {
                    let result = try decoder.decode(RetType.self, from: jsonData)
                    completion(APIResult.Result(result: result))
                } catch (let error) {
                    print(error.localizedDescription)
                    completion(APIResult.Error(string: error.localizedDescription))
                }
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
            executeAPI(urlRequest: urlReq, dateDecodingStrategy: .secondsSince1970, completion: completion)
        }
        
        public func getUser(accessToken: AccessToken, completion: @escaping ((APIResult<User>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/user")
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getNamespaces(accessToken: AccessToken, completion: @escaping ((APIResult<[Namespace]>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/namespaces")
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getUserProjects(accessToken: AccessToken, userId: UInt64, completion: @escaping ((APIResult<[Project]>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/users/\(userId)/projects", queryParams: ["order_by": "last_activity_at"])
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getGroupProjects(accessToken: AccessToken, groupId: UInt64, completion: @escaping ((APIResult<[Project]>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/groups/\(groupId)/projects", queryParams: ["order_by": "last_activity_at"])
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getProjectPipelines(accessToken: AccessToken, project: Project, completion: @escaping ((APIResult<[Pipeline]>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/projects/\(project.id)/pipelines")
            executeAPI(urlRequest: urlReq, completion: completion)
        }
        
        public func getProjectPipelineJobs(accessToken: AccessToken, projectId: UInt64, pipelineId: UInt64, completion: @escaping ((APIResult<[Job]>) -> Void)) {
            let urlReq = loggedInRequest(accessToken: accessToken, path: "/projects/\(projectId)/pipelines/\(pipelineId)/jobs")
            executeAPI(urlRequest: urlReq, completion: completion)
        }
    }
}
