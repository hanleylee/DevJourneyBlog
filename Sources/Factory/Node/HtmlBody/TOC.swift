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
    static func toc() -> Node {
        .group(
            .div(
                .class("sidebar")
            )
        )
    }

    static func tocScript() -> Node {
        .raw("""
                <script src="/js/toc.js"></script>
            """
        )
    }
}
