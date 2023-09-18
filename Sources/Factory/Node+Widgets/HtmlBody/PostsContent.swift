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
    static func postContent<T: Website>(for items: [Item<T>], on site: T) -> Node {
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        let sortedItems = items.sorted {
            $0.date < $1.date
        }

        return
            .wrapper(
                .ul( // Create an unordered list
                    .class("item-list"), // Loop over each blog post that we have in our code
                    .forEach(
                        sortedItems
                    ) { item in
                        .li( // Creates a list item for each post
                            .article( // Creates an article node to display our information
                                .h1( // Creates a heading with our post title
                                    .a( // Creates an anchor tag so we can create the link to our post
                                        // Creates the link to our post so we can click it and read everything
                                        .href(item.path),
                                        .text(item.title)
                                    )
                                ),
                                // Creates a description  of what our post is about
                                .tagList(for: item.tags, on: site),
                                .p(.text(item.description)),
                                .p(.text("Published: \(formatter.string(from: item.lastModified))"))
                            )
                        )
                    }
                )
            )
    }
}
