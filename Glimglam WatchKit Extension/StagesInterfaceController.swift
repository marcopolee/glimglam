//
//  StagesInterfaceController.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 15/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit
import Foundation

class StagesInterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!
    
    class Context: InterfaceContext {
        let pipeline: GitLab.Pipeline
        let project: GitLab.Project
        init(context: CoreContext, project: GitLab.Project, pipeline: GitLab.Pipeline) {
            self.project = project
            self.pipeline = pipeline
            super.init(context: context)
        }
    }
    
    struct State {
        let jobs: [GitLab.Job]
    }
    
    var state = State(jobs: []) {
        didSet {
            render()
        }
    }
    var context: Context!
    
    override func awake(withContext context: Any?) {
        self.context = context as! Context
    }
    
    func refreshData() {
        GitLab.API().getProjectPipelineJobs(accessToken: context.context.gitLabLogin!, projectId: context.project.id, pipelineId: context.pipeline.id) { res in
            switch res {
            case .Result(let jobs):
                self.state = State(jobs: jobs)
            case .Error(let errStr):
                print(errStr) // very sad
            }
        }
    }
    
    func render() {
        table.setNumberOfRows(state.jobs.count, withRowType: "Job")
        for i in 0..<table.numberOfRows {
            let row = table.rowController(at: i) as! StagesRowController
            row.job = state.jobs[i]
            row.render()
        }
    }
}

class StagesRowController: NSObject {
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var status: WKInterfaceLabel!
    
    var job: GitLab.Job!
    
    func render() {
        name.setText(job.stage)
        descriptionLabel.setText(job.name)
        status.setText(job.status.rawValue)
    }
}
