//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish
import ReadingTimePublishPlugin

extension Node where Context == HTML.BodyContext {
    static func tagList<T: Website>(for tags: [Tag], on site: T) -> Node {
        return
            .div(
                .forEach(tags) { tag in
                    .a(
                        .class("post-category post-category-\(tag.string.lowercased())"),
                        .href(site.path(for: tag)),
                        .text(tag.string)
                    )
                })
    }
}
