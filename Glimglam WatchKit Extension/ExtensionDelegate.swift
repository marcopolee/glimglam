//
//  ExtensionDelegate.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var context: CoreContext!
    class var shared: ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    
    struct State {
        var loggedIn = false
    }
    
    var state = State()
    var watchBridge: WatchBridge!
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        context = CoreContext()
        context.readFromKeychain()
        watchBridge = WatchBridge(context: context)
        NotificationCenter.default.addObserver(forName: .coreContextUpdate, object: nil, queue: OperationQueue.main) { [weak self] notification in
            self?.reloadRoots()
        }
        reloadRoots()
    }
    
    // Calling this will reset the UI
    func reloadRoots() {
        print("context changed previous state = \(state.loggedIn) new login = \(String(describing: context.gitLabLogin))")
        if state.loggedIn && context.gitLabLogin == nil {
            // was logged in, now not
            state.loggedIn = false
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "SignIn", context: context)])
        } else if !state.loggedIn && context.gitLabLogin != nil {
            state.loggedIn = true
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "Namespaces", context: InterfaceContext(context: context))])
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
