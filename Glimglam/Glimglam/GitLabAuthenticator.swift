//
//  GitLabAuthenticator.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 13/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class GitLabAuthenticator: NSObject, SFSafariViewControllerDelegate, URLHandler {
    enum State {
        case Ready
        case WaitingForSignin
        case RequestingToken
        case Finished
        case Failed
    }
    
    let context: CoreContext
    let presenter: UIViewController
    let urlHandlers: URLHandlers
    let id = UUID()
    var stateChangeHandler: (() -> Void)?
    var error: String?
    var accessToken: GitLab.AccessToken?
    var state = State.Ready {
        didSet {
            DispatchQueue.main.async {
                if let blk = self.stateChangeHandler {
                    blk()
                }
            }
        }
    }
    
    init(context: CoreContext, presenter: UIViewController, urlHandlers: URLHandlers) {
        self.context = context
        self.presenter = presenter
        self.urlHandlers = urlHandlers
    }
    
    func startLogin() {
        if state != .Ready {
            return
        }
        state = .WaitingForSignin
        let url = authorizeEndpoint()
        print(url.absoluteString)
        let vc = SFSafariViewController(url: authorizeEndpoint())
        presenter.present(vc, animated: true)
        self.urlHandlers.register(handler: self)
    }
    
    func handleIncoming(url: URL) -> Bool {
        if state != .WaitingForSignin {
            return false
        }
        guard let cmp = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        let expectedCmp = URLComponents(string: Secrets.GitLab.RedirectURI)!
        if cmp.scheme != expectedCmp.scheme ||
            cmp.host != expectedCmp.host ||
            cmp.path != expectedCmp.path {
            return false
        }
        // From this point onward, it's verified to be INTENDED to be a redirect URL
        // which means any failures => real failure
        guard let query = cmp.queryItems?.reduce(into: [String: String](), { (dict, item) in
            dict[item.name] = item.value
        }) else {
            return fail(message: "Invalid response from GitLab")
        }
        if query["state"] != id.uuidString {
            return fail(message: "Invalid response from GitLab")
        }
        guard let code = query["code"] else {
            return fail(message: "Missing access code from GitLab")
        }
        requestAccessToken(code: code)
        
        return fail()
    }
    
    func requestAccessToken(code: String) {
        if state != .WaitingForSignin {
            return
        }
        state = .RequestingToken
        let api = GitLab.API()
        api.postOAuthToken(clientId: Secrets.GitLab.ClientId, clientSecret: Secrets.GitLab.ApplicationSecret, code: code, grantType: "authorization_code", redirectURI: Secrets.GitLab.RedirectURI) { result in
            switch result {
            case .Error(let errStr):
                print(errStr)
                self.fail(message: errStr)
            case .Result(let res):
                self.accessToken = res
                self.state = .Finished
            }
        }
    }
    
    @discardableResult private func fail(message: String? = nil) -> Bool {
        state = .Failed
        return false
    }
    
    private func authorizeEndpoint() -> URL {
        var cmp = URLComponents()
        cmp.queryItems = [
            URLQueryItem(name: "client_id", value: Secrets.GitLab.ClientId),
            URLQueryItem(name: "redirect_uri", value: Secrets.GitLab.RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: id.uuidString)
        ]
        cmp.scheme = "https"
        cmp.host = "gitlab.com"
        cmp.path = "/oauth/authorize"
        return cmp.url!
    }
    
    
}
