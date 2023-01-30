//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Plot
import Publish

extension DevJourneyHTMLFactory {
    func postsHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .siteHeader(for: section, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: section.id),
                .container(
                    .wrapper(
                        .viewContainer(
                            .centerContent(.archiveView(context: context)),
                            .sideNav(
                                .div(
                                    .class("sideTags"),
                                    .ul(
                                        .class("all-tags"),
                                        .forEach(context.allTags.sorted()) { tag in
                                            .li(
                                                .class(tag.colorfiedClass),
                                                .a(
                                                    .href(context.site.path(for: tag)),
                                                    .text("\(tag.string) (\(tag.count))")
                                                )
                                            )
                                        }
                                    )
                                )
                            )
                        )
                    )
                ),
                .commonFooter(for: context.site)
            )
        )
    }
}
