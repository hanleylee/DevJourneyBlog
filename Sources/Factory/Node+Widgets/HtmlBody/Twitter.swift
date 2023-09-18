//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func twitterIntent(title: String, url: String) -> Node {
        .div(
            .class("post-actions"),
            .a(
                .img(
                    .class("twitterIntent"),
                    .src("/img/twitter.svg")
                ),
                .href("https://twitter.com/intent/tweet?text=\(title)&url=\(url)&via=Hanley_Lei"),
                .target(.blank),
                .rel(.nofollow),
                .rel(.noopener),
                .rel(.noreferrer)
            )
        )
    }
}
