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
                .headerLogo(),
                .headerIcons(),
                headerSections(for: context, selectedSection: selectedSection)
            )
        )
    }

    static func headerLogo() -> Node {
        return .div(
            .class("headerLogo"),
            .a(.href("/"), .img(.src("/img/icon_site.JPG")))
        )
    }

    static func headerIcons() -> Node {
        .div(
            .class("headerIcons"),
            .a(.class("icon headIconTwitter"), .href("https://www.twitter.com/Hanley_Lei"), .target(.blank), .rel(.nofollow), .rel(.noopener), .rel(.noreferrer)),
            .a(.class("icon headIconEmail"), .href("mailto:hanley.lei@gmail.com"), .target(.blank), .rel(.nofollow), .rel(.noopener), .rel(.noreferrer)),
            .a(.class("icon headIconGithub"), .href("https://github.com/hanleylee/"), .target(.blank), .rel(.nofollow), .rel(.noopener), .rel(.noreferrer)),
            .a(.class("icon headIconZhihu"), .href("https://www.zhihu.com/column/HanleyLee"), .target(.blank), .rel(.nofollow), .rel(.noopener), .rel(.noreferrer)),
            .a(.class("icon headIconRss"), .href("/feed.rss"), .target(.blank), .rel(.nofollow), .rel(.noopener), .rel(.noreferrer))
        )
    }

    static func headerSections<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases
        return .div(
            .class("headerSections"),
            .nav(
                .ul(
                    .forEach(sectionIDs) { section in
                        .li(
                            .a(
                                .class(section == selectedSection ? "selected" : ""),
                                .if(section as? DevJourneyBlog.SectionID == .recent, .href(context.index.path),
                                    else: .href(context.sections[section].path)),
                                .text(context.sections[section].title)
                            )
                        )
                    }
                ),
                .div(
                    .class("weixinHeadQcode"),
                    .onclick(
                        """
                        $('.weixinHeadQcode').css('display','none');
                        """
                    )
                )
            )
        )
    }
}
