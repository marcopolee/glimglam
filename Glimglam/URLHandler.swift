//
//  URLHandler.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 13/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import Foundation

@objc protocol URLHandler {
    func handleIncoming(url: URL) -> Bool
}

class URLHandlers: URLHandler {
    class WeakRef<T: AnyObject> {
        weak var value: T?
        init(_ value: T) {
            self.value = value
        }
    }
    
    private var handlers = [WeakRef<URLHandler>]()
    
    private func garbageCollectHandlers() {
        handlers = handlers.filter{ $0.value != nil }
    }
    
    func register(handler: URLHandler) {
        handlers.append(WeakRef<URLHandler>(handler))
    }
    
    func handleIncoming(url: URL) -> Bool {
        garbageCollectHandlers()
        for handlerRef in handlers {
            if handlerRef.value?.handleIncoming(url: url) == true {
                return true
            }
        }
        return false
    }
}
