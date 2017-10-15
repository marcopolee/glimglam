//
//  ProjectsInterfaceController.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 15/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit
import Foundation

class ProjectsInterfaceController: WKInterfaceController {
    class Context: InterfaceContext {
        let namespace: GitLab.Namespace
        init(context: CoreContext, namespace: GitLab.Namespace) {
            self.namespace = namespace
            super.init(context: context)
        }
    }
    var context: Context!
    @IBOutlet var table: WKInterfaceTable!
    
    struct State {
        let projects: [GitLab.Project]
    }
    
    var state = State(projects: []) {
        didSet {
            render()
        }
    }
    
    override func awake(withContext context: Any?) {
        self.context = context as! Context
        refreshData()
    }
    
    func refreshData() {
        let handler: (APIResult<[GitLab.Project]>) -> Void = { res in
            switch res {
            case .Result(let projects):
                self.state = State(projects: projects)
            case .Error(let errStr):
                print(errStr) // very sad
            }
        }
        switch context.namespace.kind {
        case .Group:
            GitLab.API().getGroupProjects(accessToken: context.context.gitLabLogin!, groupId: context.namespace.id, completion: handler)
        case .User:
            GitLab.API().getUserProjects(accessToken: context.context.gitLabLogin!, userId: context.namespace.id, completion: handler)
        }
    }
    
    func render() {
        table.setNumberOfRows(state.projects.count, withRowType: "Project")
        for i in 0..<table.numberOfRows {
            let row = table.rowController(at: i) as! ProjectRowController
            row.project = state.projects[i]
            row.render()
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        let project = state.projects[rowIndex]
        let context = ActionsInterfaceController.Context(context: self.context.context, project: project)
        return context
    }
}

class ProjectRowController: NSObject {
    var project: GitLab.Project!
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var path: WKInterfaceLabel!
    
    
    func render() {
        name.setText(project.name)
        path.setText(project.nameWithNamespace)
    }
}
