//
//  NamespacesInterfaceController.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 15/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit
import Foundation

class NamespacesInterfaceController: WKInterfaceController {
    var context: InterfaceContext!
    @IBOutlet var table: WKInterfaceTable!
    
    struct State {
        let namespaces: [GitLab.Namespace]
    }
    
    var state = State(namespaces: []) {
        didSet {
            render()
        }
    }
    
    override func awake(withContext context: Any?) {
        self.context = context as! InterfaceContext
        refreshData()
    }
    
    func refreshData() {
        GitLab.API().getNamespaces(accessToken: context.context.gitLabLogin!) { res in
            switch res {
            case .Result(let namespaces):
                self.state = State(namespaces: namespaces)
            case .Error(let errStr):
                print(errStr) // very sad
            }
        }
    }
    
    func render() {
        table.setNumberOfRows(state.namespaces.count, withRowType: "Namespace")
        for i in 0..<table.numberOfRows {
            let row = table.rowController(at: i) as! NamespaceRowController
            row.namespace = state.namespaces[i]
            row.render()
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        let namespace = state.namespaces[rowIndex]
        return ProjectsInterfaceController.Context(context: context.context, namespace: namespace)
    }
}

class NamespaceRowController: NSObject {
    var namespace: GitLab.Namespace!
    @IBOutlet var name: WKInterfaceLabel!
    
    func render() {
        name.setText(namespace.name)
    }
}
