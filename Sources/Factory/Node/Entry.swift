//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish
import Plot

extension Node {
    static func entry<Site: Website>(content: PublishingContext<Site>, includeCode: Bool) -> Node {
        let items = content.allItems(sortedBy: \.date)
        return .forEach(items.enumerated()) { _, item in
            .element(
                named: "entry",
                nodes: [
                    .element(named: "title", text: item.title),
                    .selfClosedElement(
                        named: "link", attributes: [.init(name: "href", value: "/" + item.path.string)]
                    ),
                    .element(named: "url", text: "/" + item.path.string),
                    .element(
                        named: "content",
                        nodes: [
                            .attribute(named: "type", value: "html"),
                            .raw("<![CDATA[" + item.htmlForSearch(includeCode: includeCode) + "]]>")
                        ]
                    ),
                    .forEach(item.tags) { tag in
                        .element(named: "tag", text: tag.string)
                    }
                ]
            )
        }
    }
}

