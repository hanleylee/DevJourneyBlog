//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func commonFooter<T: Website>(for _: T) -> Node {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return .footer(
            .p(
                .text("Copyright &copy; Hanley Lee \(formatter.string(from: Date())) "),
                .a(.text("豫ICP备20000113号"), .href("http://beian.miit.gov.cn"))
            ),
            .p(
                .text("Generated using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish"),
                    .target(.blank)
                )
            ),
            .ul(
                .li(
                    .a(
                        .img(
                            .class("twitter"),
                            .src("/img/twitter.svg")
                        ),
                        .href("https://twitter.com/Hanley_Lei"),
                        .target(.blank)
                    )
                ),
                .li(
                    .a(
                        .img(.src("/img/github.svg")),
                        .href("https://github.com/hanleylee/"),
                        .target(.blank)
                    )
                ),
                .li(
                    .a(
                        .img(.src("/img/zhihu.svg")),
                        .href("https://www.zhihu.com/column/HanleyLee"),
                        .target(.blank)
                    )
                ),
                .li(
                    .a(
                        .img(.src("/img/rss.svg")),
                        .href("/feed.rss")
                    )
                )
            )
//            .raw(googleAndBaidu)
        )
    }
}

private let googleAndBaidu = """
<script>
    // dynamic User by Hux
    var _gaId = 'UA-165296388-1';
    var _gaDomain = 'fatbobman.com';

    // Originial
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

    ga('create', _gaId, _gaDomain);
    ga('send', 'pageview');
</script>
"""
