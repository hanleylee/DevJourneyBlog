//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/2/1.
//

import Foundation
import Markdown

internal struct HeadingFinder: MarkupWalker {
    var heading1: String? = nil
    mutating func visitHeading(_ heading: Heading) {
        guard heading1 == nil else { return }

        if heading.level == 1 {
            heading1 = heading.plainText
        }
    }
}
//        var headingFinder = HeadingFinder()
//        headingFinder.visit(document)

