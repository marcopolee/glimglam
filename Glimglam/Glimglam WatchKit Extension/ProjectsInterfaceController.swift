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
    var context: InterfaceContext!
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
        self.context = context as! InterfaceContext
        refreshData()
    }
    
    func refreshData() {
        GitLab.API().getProjects(accessToken: context.context.gitLabLogin!) { res in
            switch res {
            case .Result(let projects):
                self.state = State(projects: projects)
            case .Error(let errStr):
                print(errStr) // very sad
            }
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
}

class ProjectRowController {
    var project: GitLab.Project!
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var path: WKInterfaceLabel!
    
    
    func render() {
        name.setText(project.name)
        path.setText(project.pathWithNamespace)
    }
}
