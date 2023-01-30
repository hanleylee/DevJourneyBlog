//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func headerIcons() -> Node {
        .div(
            .div(
                .class("headerIcons"),
                .a(
                    .class("icon headIconTwitter"),
                    .href("https://www.twitter.com/Hanley_Lei"),
                    .target(.blank),
                    .rel(.nofollow),
                    .rel(.noopener),
                    .rel(.noreferrer)
                ),
                .a(
                    .class("icon headIconEmail"),
                    .href("mailto:hanley.lei@gmail.com"),
                    .target(.blank),
                    .rel(.nofollow),
                    .rel(.noopener),
                    .rel(.noreferrer)
                ),
                .a(
                    .class("icon headIconGithub"),
                    .href("https://github.com/hanleylee/"),
                    .target(.blank),
                    .rel(.nofollow),
                    .rel(.noopener),
                    .rel(.noreferrer)
                ),
                .a(
                    .class("icon headIconZhihu"),
                    .href("https://www.zhihu.com/column/HanleyLee"),
                    .target(.blank),
                    .rel(.nofollow),
                    .rel(.noopener),
                    .rel(.noreferrer)
                ),
                .a(
                    .class("icon headIconRss"),
                    .href("/feed.rss"),
                    .target(.blank),
                    .rel(.nofollow),
                    .rel(.noopener),
                    .rel(.noreferrer)
                )
            )
        )
    }
}
