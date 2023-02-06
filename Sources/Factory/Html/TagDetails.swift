//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish

extension DevJourneyHTMLFactory {
    func tagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .siteHeader(for: page, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: DevJourneyBlog.SectionID.search as? Site.SectionID),
                .container(
                    .wrapper(
                        .div(
                            .class("tagResultContent"),
                            .ul(
                                .class("all-tags"),
                                .forEach(context.allTags.sorted()) { tag in
                                    .li(
                                        .class(((tag == page.tag) ? "selectedTag " : "") + tag.colorfiedClass),
                                        .a(
                                            .href(context.site.path(for: tag)),
                                            .text("\(tag.string) (\(tag.count))")
                                        )
                                    )
                                }
                            )
                        ),
                        .div(
                            .class("tagResult"),
                            .itemList(
                                for: context,
                                items: context.items(
                                    taggedWith: page.tag,
                                    sortedBy: \.date,
                                    order: .descending
                                ),
                                limit: .max
                            )
                        )
                    ),
                    .tagDetailSpacer()
                ),
                .commonFooter(for: context.site)
            )
        )
    }
}
