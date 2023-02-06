//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/2/6.
//

import Foundation
import Plot
import Publish

private let mdRaw = """
## 关于我

半路出家程序员, 喜欢折腾, 热爱编程, 拒绝做浪费时间的事情, 目前在深圳一家互联网金融公司任 iOS 开发工程师

![himg](../img/avatar.jpg)

## 技术

- iOS 开发者
- Swifter
- Vimer

## 我的开源项目

- [alfred-eudic-workflow](https://github.com/hanleylee/alfred-eudic-workflow): Alfred 的 Eudic 插件
- [dotvim](https://github.com/hanleylee/dotvim): 我的 Vim 配置

## 关于本网站

源码: <https://github.com/hanleylee/DevJourneyBlog>

本网站开发时大量借鉴了以下项目, 在此对开源社区表示万分感谢

- <https://github.com/JohnSundell/Publish>
- <https://www.fatbobman.com>

## 联系我

- Email: [hanley.lei@gmail.com](mailto:hanley.lei@gmail.com)
- Telegram: <https://t.me/hanleylee>
"""

extension HTML {
    static func about<Site>(for page: Section<Site>, context: PublishingContext<Site>) -> HTML {
        return HTML(
            .lang(context.site.language),
            .siteHeader(for: page, on: context.site),
            .body(
                .pageHeader(for: context, selectedSection: DevJourneyBlog.SectionID.about as? Site.SectionID),
                .container(
                    .wrapper(
                        .div(
                            .class("about"),
                            .article(
                                .div(
                                    .class("content"),
                                    .raw(context.markdownParser.parse(mdRaw).html)
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
