//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

public extension Tag {
    private static var countMap: [Tag: Int] = [:]

    static func generateCount<T: Website>(content: PublishingContext<T>) {
        for tag in content.allTags {
            countMap[tag] = content.items(taggedWith: tag).count
        }
    }

    var count: Int {
        Tag.countMap[self] ?? 0
    }

    var colorfiedClass: String {
        return TagColorfier.colorfiedClass(for: self)
    }
}
