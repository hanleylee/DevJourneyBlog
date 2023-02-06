//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/2/6.
//

import Foundation
import Plot
import Publish

extension HTML {
    static func common<Site>(for page: Page, context: PublishingContext<Site>) -> HTML {
        return HTML(
            .lang(context.site.language),
            .siteHeader(for: page, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: nil),
                .container(
                    .wrapper(
                        .div(
                            .class("page-common"),
                            .article(
                                .div(
                                    .class("content"),
                                    .contentBody(page.body)
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
