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
    static func tagList<T: Website>(
        for item: Item<T>,
        on site: T,
        displayDate: Bool = false
    ) -> Node {
        return .ul(
            .class("tag-list"),
            .forEach(item.tags) { tag in
                .li(.class(tag.colorfiedClass), .a(.href(site.path(for: tag)), .text(tag.string)))
            },
            .li(
                .class("tag tagdate"),
                .if(displayDate, .text(CommonTools.formatter.string(from: item.date)))
            )
        )
    }
}
