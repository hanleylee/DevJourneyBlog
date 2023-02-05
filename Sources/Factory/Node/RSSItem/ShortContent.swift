//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish
import Sweep

extension Node where Context: RSSItemContext {
    static func shortContent<T>(for item: Item<T>, site: T) -> Node {
        let baseURL = site.url
        let prefixes = (href: "href=\"", src: "src=\"")

        var html = item.rssProperties.bodyPrefix ?? ""
        // 添加了截取设置
        html.append(item.body.htmlDescription(words: 450, keepImageTag: false, ellipsis: "<a href=\(baseURL)/\(item.path)>...></a>"))
        html.append(item.rssProperties.bodySuffix ?? "")

        var links = [(url: URL, range: ClosedRange<String.Index>, isHref: Bool)]()

        html.scan(using: [
            Matcher(
                identifiers: [
                    .anyString(prefixes.href),
                    .anyString(prefixes.src),
                ],
                terminators: ["\""],
                handler: { url, range in
                    guard url.first == "/" else { return }

                    let absoluteURL = baseURL.appendingPathComponent(String(url))
                    let isHref = (html[range.lowerBound] == "h")
                    links.append((absoluteURL, range, isHref))
                }
            ),
        ])

        for (url, range, isHref) in links.reversed() {
            let prefix = isHref ? prefixes.href : prefixes.src
            html.replaceSubrange(range, with: prefix + url.absoluteString + "\"")
        }

        html.append(contentsOf: "<br><br><h3><a href=\(baseURL)/\(item.path)>查看全文</a></h3>")

        return content(html)
    }
}
