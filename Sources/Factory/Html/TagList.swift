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
    func tagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        return HTML(
            .lang(context.site.language),
            .siteHeader(for: page, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: DevJourneyBlog.SectionID.tags as? Site.SectionID),
                .container(
                    .wrapper(
                        .div(
                            .class("searchContent"),
                            .searchInput(),
                            .ul(
                                .class("all-tags"),
                                .forEach(page.tags.sorted()) { tag in
                                    .li(
                                        .class(tag.colorfiedClass),
                                        .a(
                                            .href(context.site.path(for: tag)),
                                            .text("\(tag.string) (\(tag.count))")
                                        )
                                    )
                                }
                            ),
                            .searchResult()
                        )
                    )
                ),
                .commonFooter(for: context.site)
            )
        )
    }
}
