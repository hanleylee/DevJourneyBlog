//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish
import Plot

extension Node where Context == HTML.BodyContext {
    static func itemNavigator<Site: Website>(previousItem: Item<Site>?, nextItem: Item<Site>?) -> Node {
        .div(
            .class("item-navigator"),
            .table(
                .tr(
                    .if(
                        previousItem != nil,
                        .td(
                            .class("previous-item"),
                            .a(
                                .href(previousItem?.path ?? Path("")),
                                .text(previousItem?.title ?? "")
                            )
                        ),
                        else:
                        .td(
                            .text("")
                        )

                    ),
                    .if(
                        nextItem != nil,
                        .td(
                            .class("next-item"),
                            .a(
                                .href(nextItem?.path ?? Path("")),
                                .text(nextItem?.title ?? "")
                            )
                        ),
                        else:
                        .td(
                            .text("")
                        )
                    )
                )
            )
        )
    }
}
