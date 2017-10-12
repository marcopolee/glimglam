//
//  ViewController.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import UIKit
import GlimglamCore
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate {
    
    let state = UUID()
    var context: CoreContext!
    
    override func viewDidAppear(_ animated: Bool) {
        if context.gitLabLogin == nil {
            startLogin()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLogin() {
        let vc = SFSafariViewController(url: authorizeEndpoint())
        present(vc, animated: true)
    }
    
    func authorizeEndpoint() -> URL {
        var cmp = URLComponents()
        cmp.queryItems = [
            URLQueryItem(name: "client_id", value: Secrets.GitLab.ClientId),
            URLQueryItem(name: "redirect_uri", value: Secrets.GitLab.RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state.uuidString)
        ]
        cmp.host = "www.gitlab.com"
        cmp.scheme = "https"
        return cmp.url!
    }
}
