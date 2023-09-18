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
    static func recentItemList<Site: Website>(
        for _: Index,
        context: PublishingContext<Site>,
        recentPostNumber: Int = 5,
        words: Int = 300
    ) -> Node {
        let items = context.allItems(sortedBy: \.date, order: .descending)
        guard items.count > 1 else {
            return .empty
        }

        return
            .div(
                .class("index-list"),
                .ul(
                    .class("indexul"),
                    .forEach(items.prefix(recentPostNumber)) { item in
                        .li(
                            .class("indexli"),
                            .div(
                                .class("index-title"),
                                .a(
                                    .href(item.path),
                                    .h1(.text(item.title))
                                )
                            ),
                            .div(
                                .tagList(for: item, on: context.site, displayDate: true)
                            ),
                            .div(
                                .class("content"),
                                .article(
                                    .raw(
                                        item.content.body.htmlDescription(
                                            words: words,
                                            keepImageTag: true,
                                            ellipsis: "..."
                                        )
                                    )
                                ),
                                .div(
                                    .class("index-item-more float-container"),
                                    .a(
                                        .href(item.path),
                                        .text("查看全文")
                                    )
                                )
                            )
                        )
                    }
                )
            )
    }
}
