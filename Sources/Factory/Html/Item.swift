//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension DevJourneyHTMLFactory {
    func itemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        var previous: Item<Site>?
        var next: Item<Site>?

        let items = context.allItems(sortedBy: \.date, order: .descending)
        guard let index = items.firstIndex(where: { $0 == item }) else { return HTML() }

        if index > 0 { previous = items[index - 1] }

        if index < (items.count - 1) { next = items[index + 1] }

        return HTML(
            .lang(context.site.language),
            .siteHeader(for: item, on: context.site),
            .body(
                .class("item-page"),
                .pageHeader(for: context, selectedSection: item.sectionID),
                .container(
                    .wrapper(
                        .viewContainer(
                            .centerContent(
                                .shareContainer(title: item.title, url: context.site.url.appendingPathComponent(item.path.string).absoluteString),
                                .article(
                                    .div(
                                        .class("post-title"),
                                        .h1(
                                            .text(item.title)
                                        )
                                    ),
                                    .div(
                                        .tagList(for: item, on: context.site, displayDate: true),
                                        .div(
                                            .class("content"),
                                            .contentBody(item.body)
                                        ),
                                        .license()
                                    )
                                ),
                                .itemNavigator(previousItem: previous, nextItem: next)
//                                .gitTalk(topicID: item.title)
                            ),
                            .sideNav(.toc()),
                            .tocScript() // 必须在文档加载后，才能调用script
                        )
                    ),
                    .commonFooter(for: context.site)
                )
            )
        )
    }
}
