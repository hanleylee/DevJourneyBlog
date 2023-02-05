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
    static func itemList<T: Website>(for context: PublishingContext<T>, items: [Item<T>], limit: Int = .max) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items.prefix(10)) { item in
                .li(
                    .article(
                        .h1(
                            .class("itme-list-title"),
                            .a(
                                .href(item.path),
                                .text(item.title)
                            )
                        ),
                        .tagList(for: item, on: context.site, displayDate: true),
                        .div(
                            .class("content"),
                            .raw(context.markdownParser.parse(item.description).html)
//                            .markdown(item.description)
                        ),
                        .if(item.imagePath != nil, .div(.img(.src(item.imagePath?.absoluteString ?? ""))))
                    )
                )
            }
        )
    }
}
