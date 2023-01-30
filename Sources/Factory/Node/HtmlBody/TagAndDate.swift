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
    static func tagAndDate(tags: Node, date: Date) -> Node {
        return .div(
            .class("publishDate"),
            .table(
                .tr(
                    .td(tags),
                    .td(.text(CommonTools.formatter.string(from: date)))
                )
            )
        )
    }
}
