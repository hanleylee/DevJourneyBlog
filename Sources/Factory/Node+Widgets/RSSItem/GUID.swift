//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension Node where Context: RSSItemContext {
    static func guid<T>(for item: Item<T>, site: T) -> Node {
        return .guid(
            .text(item.rssProperties.guid ?? site.url(for: item).absoluteString),
            .isPermaLink(item.rssProperties.guid == nil && item.rssProperties.link == nil)
        )
    }
}
