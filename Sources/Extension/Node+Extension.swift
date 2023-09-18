//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {

    static func viewContainer(_ nodes: Node...) -> Node {
        .div(
            .class("viewContainer"),
            .group(nodes)
        )
    }

    static func container(_ nodes: Node...) -> Node {
        .div(
            .class("container"),
            .group(nodes)
        )
    }

    static func centerContent(_ nodes: Node...) -> Node {
        .div(
            .class("centerContent"),
            .group(nodes)
        )
    }

    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
}
