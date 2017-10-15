//
//  AppDelegate.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    var navigationController: UINavigationController!
    var watchBridge: WatchBridge!
    let urlHandlers = URLHandlers()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let mainNavVC = window?.rootViewController as! UINavigationController
        navigationController = mainNavVC
        bootstrapContext()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.absoluteString)
        return urlHandlers.handleIncoming(url: url)
    }
    
    func bootstrapContext() {
        let mainVC = navigationController.viewControllers.first as! ViewController
        let context = CoreContext()
        context.readFromKeychain()
        mainVC.context = context
        watchBridge = WatchBridge(context: context)
    }
}

