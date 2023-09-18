//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func postsBy(author: String, section: Section<DevJourneyBlog>, on site: DevJourneyBlog) -> Node {
        let items = section.items.filter {
            $0.metadata.author == author
        }

        return
            .wrapper(
                .div(
                    .h1("Posts by \(author)"),
                    .postContent(for: items, on: site)
                )
            )
    }
}
