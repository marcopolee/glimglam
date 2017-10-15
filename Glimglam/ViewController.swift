//
//  ViewController.swift
//  Glimglam
//
//  Created by Tyrone Trevorrow on 12/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate {
    var context: CoreContext!
    var authenticator: GitLabAuthenticator?
    
    @IBOutlet var notSignedInView: UIStackView!
    @IBOutlet var signedInView: UIStackView!
    
    override func viewDidAppear(_ animated: Bool) {
        render()
    }
    
    func render() {
        if context.gitLabLogin == nil {
            // Show not signed in view
            signedInView.isHidden = true
            notSignedInView.isHidden = false
        } else {
            // ??
            signedInView.isHidden = false
            notSignedInView.isHidden = true
        }
    }
    
    func authenticatorStateChanged() {
        guard let auth = authenticator else {
            return
        }
        switch auth.state {
        case .Finished:
            dismiss(animated: true)
            print("Logged in and got token! Auth Token = \(auth.accessToken!.accessToken)")
            print(try! JSONEncoder().encode(auth.accessToken))
            context.gitLabLogin = auth.accessToken
            context.user = auth.user
            context.storeInKeychain()
        default:
            break
        }
        render()
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        let auth = GitLabAuthenticator(context: context, presenter: self, urlHandlers: AppDelegate.shared.urlHandlers)
        auth.stateChangeHandler = { [weak self] in
            self?.authenticatorStateChanged()
        }
        authenticator = auth
        auth.startLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
