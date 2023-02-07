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
    static func supporter<Site>(for page: Page, context: PublishingContext<Site>) -> HTML {
        let support =
            """
            如果您希望我在文章中探讨某方面的话题, 请在 [Twitter](https://twitter.com/Hanley_Lei) 或 [Email](mailto:hanley.lei@gmail.com) 中告诉我
            """
        return HTML(
            .lang(context.site.language),
            .siteHeader(for: page, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: nil),
                .container(
                    .wrapper(
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
                                    .width(500),
                                    .height(500)
                                )
                            ),
                            .p(
                                .text("您的支持和鼓励将为我写作增添更多的动力!")
                            )
                        )
                    )
                )
            )
        )
    }
}
