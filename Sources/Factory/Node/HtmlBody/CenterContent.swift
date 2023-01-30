//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/18.
//

import Foundation
import Publish
import Plot

extension Node where Context == HTML.BodyContext {
    static func centerContent(_ nodes: Node...) -> Node {
        .div(
            .class("centerContent"),
            .group(nodes)
        )
    }
}
