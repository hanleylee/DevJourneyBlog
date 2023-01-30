//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot

extension Node where Context == HTML.ListContext {
    static func itemDate(date: Date) -> Node {
        return .li(
            .class("tag-list date"),
            .text(CommonTools.formatter.string(from: date))
        )
    }
}

