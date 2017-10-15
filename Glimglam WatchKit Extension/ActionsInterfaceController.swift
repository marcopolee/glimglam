//
//  ActionsInterfaceController.swift
//  Glimglam WatchKit Extension
//
//  Created by Tyrone Trevorrow on 15/10/17.
//  Copyright © 2017 Marco Polee. All rights reserved.
//

import WatchKit
import Foundation

class ActionsInterfaceController: WKInterfaceController {
    class Context: InterfaceContext {
        let project: GitLab.Project
        init(context: CoreContext, project: GitLab.Project) {
            self.project = project
            super.init(context: context)
        }
    }
    var context: Context!
    
    override func awake(withContext context: Any?) {
        self.context = context as! Context
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch segueIdentifier {
        case "PushPending":
            return PipelinesInterfaceController.Context(context: context.context, filter: .Pending, project: context.project)
        case "PushRunning":
            return PipelinesInterfaceController.Context(context: context.context, filter: .Running, project: context.project)
        case "PushFinished":
            return PipelinesInterfaceController.Context(context: context.context, filter: .Finished, project: context.project)
        default:
            return nil
        }
    }
}
