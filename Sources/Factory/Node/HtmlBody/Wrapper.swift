//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func nav<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases
        return .nav(
            .ul(
                .forEach(sectionIDs) { section in
                    .li(
                        .a(
                            .if(
                                section as! DevJourneyBlog.SectionID == .about,
                                .class("selected")
                            ),
                            .class(section == selectedSection ? "selected" : ""),
                            .if(section as! DevJourneyBlog.SectionID == .recent, .href(context.index.path),
                                else: .href(context.sections[section].path)),
                            .text(context.sections[section].title)
                        )
                    )
                }
            ),
            .div(
                .class("weixinHeadQcode"),
                .onclick(
                    """
                    $('.weixinHeadQcode').css('display','none');
                    """
                )
            )
        )
    }

    // static func toc(_ nodes: Node<HTML.BodyContext>...) -> Node {
    //     .element(named: "sidebar", nodes: nodes)
    // }


    static func sideNav(_ nodes: Node...) -> Node {
        .div(
            .class("side-nav"),
            .group(nodes)
        )
    }


}

/*
 <!-- Baidu Tongji -->

 <script>
     // dynamic User by Hux
     var _baId = '14e5d60a3ea6276655f9d14c58b1fcd0';

     // Originial
     var _hmt = _hmt || [];
     (function() {
       var hm = document.createElement("script");
       hm.src = "//hm.baidu.com/hm.js?" + _baId;
       var s = document.getElementsByTagName("script")[0];
       s.parentNode.insertBefore(hm, s);
     })();
 </script>
 */
