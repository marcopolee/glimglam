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
        guard let data = try? JSONEncoder().encode(context) else {
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
