//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

extension Item {
    func htmlForSearch(includeCode: Bool = true) -> String {
        var result = body.html
        result = result.replacingOccurrences(of: "]]>", with: "]>")
        if !includeCode {
            var search = true
            var check = false
            while search {
                check = false
                result.scan(using: [
                    .init(
                        identifier: "<code>", terminator: "</code>", allowMultipleMatches: false,
                        handler: { _, range in
                            result.removeSubrange(range)
                            check = true
                        }
                    )
                ])
                if !check { search = false }
            }
        }
        return result
    }

    var rssTitle: String {
        let prefix = rssProperties.titlePrefix ?? ""
        let suffix = rssProperties.titleSuffix ?? ""
        return prefix + title + suffix
    }
}
