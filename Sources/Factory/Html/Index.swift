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
    func indexHTML(for index: Location, context: PublishingContext<Site>) throws -> HTML {
//        let sections = context.sections
//        let section = sections.first(where: { $0.id.rawValue == "home" })
        return HTML(
            .lang(context.site.language),
            .siteHeader(for: index, on: context.site),
            .body(
                .class("index"),
                .pageHeader(
                    for: context,
                    selectedSection: DevJourneyBlog.SectionID.recent as? Site.SectionID
                ),
                .container(
                    .wrapper(
                        .viewContainer(
                            .centerContent(
                                .itemList(for: context, items: context.allItems(sortedBy: \.date, order: .descending), limit: 10),
                                .indexFooter(context: context)
                            ),
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

private extension Node where Context == HTML.BodyContext {
    // 首页下方的 "显示全部文章"
    static func indexFooter<Site: Website>(context: PublishingContext<Site>) -> Node {
        return .div(
            .class("section-header float-container"),
            .a(
                .class("browse-all"),
                .href("/articles/"),
                .text("显示全部文章(\(context.itemCount))")
            )
        )
    }
}
