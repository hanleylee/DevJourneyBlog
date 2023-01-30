//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension PublishingStep where Site == DevJourneyBlog {
    static func makeDateArchive() -> Self {
        step(named: "Date Archive") { content in
            var doc = Content()
            doc.title = "时间线"
            let archiveItems = dateArchive(items: content.allItems(sortedBy: \.date, order: .descending))
            let html = Node.div(
                .forEach(archiveItems.keys.sorted(by: >)) { absoluteMonth in
                    .group(
                        .h3(.text("\(absoluteMonth.monthAndYear.year)年\(absoluteMonth.monthAndYear.month)月")),
                        .ul(
                            .forEach(archiveItems[absoluteMonth]!) { item in
                                .li(
                                    .a(
                                        .href(item.path),
                                        .text(item.title)
                                    )
                                )
                            }
                        )
                    )
                }
            )
            doc.body.html = html.render()
            let page = Page(path: "archive", content: doc)
            content.addPage(page)
        }
    }

    private static func dateArchive(items: [Item<Site>]) -> [Int: [Item<Site>]] {
        let result = Dictionary(grouping: items, by: { $0.date.absoluteMonth })
        return result
    }
}

