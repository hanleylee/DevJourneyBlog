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
    func pageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        if page.path == Path("support") {
            let support =
                """
                如果您希望我在文章中探讨某方面的话题, 请在 [推特](https://twitter.com/Hanley_Lei) 或 [邮箱](mailto:hanley.lei@gmail.com) 中告诉我
                """
            return HTML(
                .lang(context.site.language),
                .siteHeader(for: page, on: context.site),
                .body(
                    .div(
                        .class("supporter"),
                        .p(
                            .markdown(support),
                            .div(
                                .class("label"),
                                .text("关注")
                            )
                        ),
                        .p(
                            .img(
                                .src("/img/wechat_reward.jpg"),
                                .alt("鼓励作者"),
                                .width(300),
                                .height(300)
                            )
                        ),
                        .p(
                            .text("您的支持和鼓励将为我写作增添更多的动力!")
                        )
                    )
                )
            )
        } else {
            return HTML(
                .lang(context.site.language),
                .siteHeader(for: page, on: context.site),
                .body(
                    .pageHeader(for: context, selectedSection: nil),
                    .container(
                        .wrapper(
                            .div(
                                .class("about"),
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
}
