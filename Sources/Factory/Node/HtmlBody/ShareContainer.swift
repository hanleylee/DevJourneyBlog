//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

// 首页的分享栏

extension Node where Context == HTML.BodyContext {
    static func shareContainer(title: String, url: String) -> Node {
        .div(
            .class("post-actions"),
            .div(
                .class("actionButton"),
                .div(
                    .class("actionButton twitter"),
                    .onclick("window.open('https://twitter.com/intent/tweet?text=\(title)&url=\(url)&via=Hanley_Lei','target','');")
                )
            ),
            .div(
                .class("actionButton"),
                .div(
                    .class("actionButton comment"),
                    .onclick("$('html,body').animate({scrollTop: $('#gitalk-container').offset().top }, {duration: 500,easing:'swing'})"
                    )
                )
            )
        )
    }
}
