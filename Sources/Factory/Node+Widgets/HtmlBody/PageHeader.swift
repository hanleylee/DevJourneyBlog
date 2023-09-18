//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/18.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    // 页面头部
    static func pageHeader<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases
        return .header(
            .wrapper(
                .div(
                    .class("logo"),
                    .a(
                        .href("/"),
                        .img(.src("/img/icon_site.JPG"))
                    )
                ),
                .headerIcons(),
                .if(sectionIDs.count > 1, nav(for: context, selectedSection: selectedSection))
            )
        )
    }
}
