//
//  PipelinesInterfaceController.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 15/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit
import Foundation

class PipelinesInterfaceController: WKInterfaceController {
    class Context: InterfaceContext {
        enum Filter: String {
            case Pending
            case Running
            case Finished
            
            func toGitLabStatus() -> [GitLab.Pipeline.Status] {
                switch self {
                case .Pending:
                    return [.Pending]
                case .Finished:
                    return [.Success, .Failed, .Skipped, .Canceled]
                case .Running:
                    return [.Running]
                }
            }
        }
        let filter: Filter
        let project: GitLab.Project
        init(context: CoreContext, filter: Filter, project: GitLab.Project) {
            self.filter = filter
            self.project = project
            super.init(context: context)
        }
    }
    
    struct State {
        let pipelines: [GitLab.Pipeline]
    }
    
    var state = State(pipelines: []) {
        didSet {
            render()
        }
    }
    var context: Context!
    @IBOutlet var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        self.context = context as! Context
    }
    
    func refreshData() {
        GitLab.API().getProjectPipelines(accessToken: context.context.gitLabLogin!, project: context.project) { res in
            switch res {
            case .Result(let pipelines):
                let filtered = self.filterPipelines(pipelines: pipelines, filter: self.context.filter)
                self.state = State(pipelines: filtered)
            case .Error(let errStr):
                print(errStr) // very sad
            }
        }
    }
    
    func filterPipelines(pipelines: [GitLab.Pipeline], filter: Context.Filter) -> [GitLab.Pipeline] {
        let acceptableStatuses = filter.toGitLabStatus()
        let filtered = pipelines.filter( { acceptableStatuses.contains($0.status!) })
        return filtered
    }
    
    func render() {
        table.setNumberOfRows(state.pipelines.count, withRowType: "Pipeline")
        for i in 0..<table.numberOfRows {
            let row = table.rowController(at: i) as! PipelineRowController
            row.pipeline = state.pipelines[i]
            row.render()
        }
    }
}

class PipelineRowController: NSObject {
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    
    var pipeline: GitLab.Pipeline!
    
    func render() {
        name.setText("#\(pipeline.id)")
        let desc = "\(pipeline.ref!) \(pipeline.sha!.prefix(8))"
        descriptionLabel.setText(desc)
    }
}
