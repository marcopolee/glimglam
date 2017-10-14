//
//  WatchBridge.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 14/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchBridge: NSObject, WCSessionDelegate {
    enum Message: String {
        case GitLabLogin
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            sendGitLabLogin()
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("received message (\(userInfo["type"] ?? "invalid message"))")
        guard let typeStr = userInfo["type"] as? String,
            let type = Message(rawValue: typeStr),
            let object = userInfo["object"] as? [String: Any] else {
            print("unrecognized message type: version mismatch maybe?")
            return
        }
        
        switch type {
        case .GitLabLogin:
            guard let data = try? JSONSerialization.data(withJSONObject: object, options: []),
                let login = try? JSONDecoder().decode(GitLab.AccessToken.self, from: data) else {
                    print("unrecognized message structure: likely programmer derp")
                    return
            }
            context.gitLabLogin = login
        }
    }
    
    let context: CoreContext
    let session: WCSession
    init(context: CoreContext) {
        self.context = context
        self.session = WCSession.default
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func sendGitLabLogin() {
        if !session.isWatchAppInstalled || session.activationState != .activated {
            return
        }
        guard let data = try? JSONEncoder().encode(context.gitLabLogin) else {
            return
        }
        guard let userInfo = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            return
        }
        send(object: userInfo, type: .GitLabLogin)
    }
    
    func send(object: [String: Any], type: Message) {
        let message: [String: Any] = [
            "type": type.rawValue,
            "object": object
        ]
        session.transferUserInfo(message)
    }
}
