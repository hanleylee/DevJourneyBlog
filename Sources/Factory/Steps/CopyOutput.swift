//
//  File.swift
//  
//
//  Created by Hanley Lee on 2024/6/9.
//

import Foundation
import Publish
import ShellOut

extension PublishingStep {
    static func copyOuput(to path: String) -> Self {
        step(named: "copy output to \(path)") { context in
            
            do {
                try shellOut(
                    to: "rsync",
                    arguments: ["-aP", "--delete", context.folders.output.path, path],
                    at: context.folders.root.path
                )
            } catch {
                print(error)
            }
        }
    }
}
