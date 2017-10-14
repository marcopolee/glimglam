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
    class Context: NSObject {
        enum Filter: String {
            case Pending
            case Running
            case Finished
        }
        let filter: Filter
        let context: CoreContext
        init(context: CoreContext, filter: Filter) {
            self.filter = filter
            self.context = context
        }
    }
    var context: Context!
    
    override func awake(withContext context: Any?) {
        self.context = context as! Context
    }
}
