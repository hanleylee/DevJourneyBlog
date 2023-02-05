//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func license() -> Node {
        .div(
            .class("license"),
            .p(
                .text("本博客文章采用 "),
                .a(
                    .text("CC 4.0 协议"),
                    .href("https://creativecommons.org/licenses/by-nc-sa/4.0/"),
                    .target(.blank)
                ),
                .text("，转载需注明出处和作者。")
            ),
            .p(
                .a(
                    .img(
                        .src("/img/support_hanley_button.png"),
                        .alt("鼓励作者"),
                        .width(200),
                        .height(53)
                    ),
                    .href("/support/")
                )
            )
        )
    }
}
