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
                                .indexFooter(context: context, showTitle: false)
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

fileprivate extension Node where Context == HTML.BodyContext {
    // ??????????????? "??????????????????"
    static func indexFooter<Site: Website>(
        context: PublishingContext<Site>,
        showTitle: Bool = true
    ) -> Node {
        return .div(
            .class("section-header float-container"),
            .if(showTitle, .h2(.text("????????????"))),
            .a(
                .class("browse-all"),
                .href("/articles/"),
                .text("??????????????????(\(context.itemCount))")
            )
        )
    }
}
