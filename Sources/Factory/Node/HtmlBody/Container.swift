//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/18.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func container(_ nodes: Node...) -> Node {
        .div(
            .class("container"),
            .group(nodes)
        )
    }
}
