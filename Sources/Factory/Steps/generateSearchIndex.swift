//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish
import Sweep

extension PublishingStep {
    static func generateSearchIndex(includeCode: Bool = true) -> PublishingStep {
        step(named: "make search index file") { content in
            let xml = XML(
                .element(
                    named: "search",
                    nodes: [
                        .entry(content: content, includeCode: includeCode)
                    ]
                )
            )
            let result = xml.render()
            do {
                try content.createFile(at: Path("/Output/search.xml")).write(result)
            } catch {
                print("Failed to make search index file error:\(error)")
            }
        }
    }
}
