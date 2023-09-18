//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func tagDetailSpacer() -> Node {
        .group(
            // 窗口变化
            .script(
                .raw(
                    """
                    $(window).resize(function(){
                        setHeight();
                    })
                    """
                )
            ),
            // 设置search-result height
            .script(
                .raw("""
                    var setHeight = function(){
                        var totalHeight = $('.item-list').get(0).offsetHeight + $('footer').get(0).offsetHeight + $('header').get(0).offsetHeight + 50
                        if (totalHeight < window.innerHeight) {
                            $('.wrapper').height( window.innerHeight - 50 - $('footer').get(0).offsetHeight - $('header').get(0).offsetHeight );
                        }
                        else {
                            $('.wrapper').height( $('.item-list').height );
                        }
                     }
                    """
                )
            ),
            .script(
                .raw(
                    """
                    $(document).ready(function(){
                        setHeight();
                    })
                    """
                )
            )
        )
    }
}
