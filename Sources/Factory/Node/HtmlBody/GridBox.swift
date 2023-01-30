//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func gridBox<Site: Website>(context _: PublishingContext<Site>) -> Node {
        return
            .ul(
                .class("item-list feature grid compact"),
                .li(
                    .a(
                        .href("/"),
                        .article(
                            .text("hgdsg"),
                            .p(.text("sdg"))
                        )
                    )
                ),
                .li(
                    .text("asadgasg")
                ),
                .li(
                    .text("sdgasasdsgasd")
                )
            )
    }
}
